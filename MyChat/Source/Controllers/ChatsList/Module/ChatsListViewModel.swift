//
//  ViewModel.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UI
import Models
import Logger
import RxSwift
import RxRelay
import Services
import CoreData
import Messaging

protocol ChatsListViewModelProtocol {
    var input: ChatsListViewModelInput { get }
    var output: ChatsListViewModelOutput { get }
}

protocol ChatsListViewModelInput {
    func viewDidLoad()

    func presentAlertController(presenter: TransitionHandler)

    func filterUsers(with name: String)
    func setupDefaultChatList()
    func setupChatCellNodeDelegate(with delegate: ChatCellNodeDelegate?, indexPath: IndexPath)
    func removeChat(at indexPath: IndexPath) -> Single<Any?>
    func presentNewChatViewController(presenterVC: TransitionHandler)
    func pushChatViewController(chat atIndexPath: IndexPath, presenterVC: TransitionHandler)
    func pushSettingsViewController(presenterVC: TransitionHandler)
}

protocol ChatsListViewModelOutput {
    var fetchResultsController: NSFetchedResultsController<CDChat> { get }
    var chatsCollectionShouldReload: PublishRelay<Any?> { get }

    // UI
    var viewControllerBackgroundColor: BehaviorRelay<UIColor> { get }
    var titleText: BehaviorRelay<String> { get }
    var searchPlaceholder: BehaviorRelay<String> { get }
    var searchFont: UIFont { get }
    var removeActionTitle: String? { get }
    var showAlert: PublishRelay<Any?> { get }
    var noChatsText: String { get }
    var noChatFont: UIFont { get }
    var noChatsFontColor: BehaviorRelay<UIColor> { get }
    var noChatsFoundText: String { get }
    var noChatsFoundFont: UIFont { get }
    var noChatsFoundColor: BehaviorRelay<UIColor> { get }
    var navBarTitleFont: UIFont { get }

    func getChatCellModel(for indexPath: IndexPath) -> ChatCellModel?
}

final class ChatsListViewModel {

    // MARK: Public properties
    var input: ChatsListViewModelInput { return self }
    var output: ChatsListViewModelOutput { return self }

    var chatsCollectionShouldReload = PublishRelay<Any?>()

    private(set) var fetchResultsController: NSFetchedResultsController<CDChat>

    // UI
    let viewControllerBackgroundColor: BehaviorRelay<UIColor>
    let titleText: BehaviorRelay<String>
    let searchPlaceholder: BehaviorRelay<String>
    let removeActionTitle: String?
    private(set) lazy var showAlert = PublishRelay<Any?>()
    let noChatsText: String
    let noChatFont: UIFont
    let noChatsFontColor: BehaviorRelay<UIColor>
    let noChatsFoundText: String
    let noChatsFoundFont: UIFont
    let noChatsFoundColor: BehaviorRelay<UIColor>
    let navBarTitleFont: UIFont
    let searchFont: UIFont

    // MARK: Private properties
    private let user: ChatUser

    private let coordinator: CoordinatorProtocol
    private let storageManager: StorageManagerProtocol
    private let imageCacheManager: ImageCacheManagerProtocol
    private let webSocketsFacade: WebSocketsFlowFacade

    private let fonts: (ChatsListViewControllerFonts) -> UIFont
    private let texts: (ChatsListViewControllerTexts) -> String
    private let palette: (ChatsListViewControllerPalette) -> UIColor

    private lazy var bag = DisposeBag()

    // MARK: Init
    init(user: ChatUser,
         coordinator: CoordinatorProtocol,
         webSocketsFacade: WebSocketsFlowFacade,
         storageManager: StorageManagerProtocol,
         imageCacheManager: ImageCacheManagerProtocol,
         fonts: @escaping (ChatsListViewControllerFonts) -> UIFont,
         texts: @escaping (ChatsListViewControllerTexts) -> String,
         palette: @escaping (ChatsListViewControllerPalette) -> UIColor) {
        self.user = user

        self.coordinator = coordinator
        self.storageManager = storageManager
        self.webSocketsFacade = webSocketsFacade
        self.imageCacheManager = imageCacheManager

        self.fetchResultsController = storageManager.getChatsFetchResultsController()

        self.fonts = fonts
        self.texts = texts
        self.palette = palette

        /// Настройка цветов
        let vcBackgroundColor = palette(.chatsListViewControllerBackgroundColor)
        self.viewControllerBackgroundColor = BehaviorRelay<UIColor>(value: vcBackgroundColor)
        self.noChatsFontColor = BehaviorRelay<UIColor>(value: palette(.chatsListViewControllerEmptyStateFontColor))
        self.noChatsFoundColor = BehaviorRelay<UIColor>(value: palette(.chatsListViewControllerEmptyStateFontColor))

        /// Настройка текстов
        self.titleText = BehaviorRelay<String>(value: texts(.title))
        self.searchPlaceholder = BehaviorRelay<String>(value: texts(.searchBarPlaceholder))
        self.removeActionTitle = texts(.deleteButtonTitle)
        self.noChatsText = texts(.noChatsText)
        self.noChatsFoundText = texts(.noChatsFoundText)

        /// Настройка шрифтов
        self.noChatFont = fonts(.emptyStateTitle)
        self.noChatsFoundFont = fonts(.emptyStateTitle)
        self.navBarTitleFont = fonts(.navBarTitle)
        self.searchFont = fonts(.searchTextfieldPlaceholder)

        /// Шрифт для всех кнопок cancel в searchBar
        let attributes: [NSAttributedString.Key: Any] = [.font: searchFont]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)

        /// Подписка на изменения темы пользователя для автоматического обновления цвета
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(shouldUpdateColors),
                                               name: NSNotification.shouldUpdatePalette,
                                               object: nil)

        /// Подписка на разрыв соединения с сервером при выходе из активного состояния
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        /// Подписка на переподключение к серверу при входе в активное состояние
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    // MARK: Objc private methods
    @objc private func shouldUpdateColors() {
        let vcBackgroundColor = palette(.chatsListViewControllerBackgroundColor)
        viewControllerBackgroundColor.accept(vcBackgroundColor)
        noChatsFontColor.accept(palette(.chatsListViewControllerEmptyStateFontColor))
        noChatsFoundColor.accept(palette(.chatsListViewControllerEmptyStateFontColor))
        chatsCollectionShouldReload.accept(nil)
    }

    @objc private func willResignActive() {
        webSocketsFacade.closeConnection()
    }

    @objc private func didBecomeActive() {
        connectToServer()
    }
}

// MARK: - extension + ChatsListViewModelProtocol -
extension ChatsListViewModel: ChatsListViewModelProtocol {}

// MARK: - extension + ChatsListViewModelInput -
extension ChatsListViewModel: ChatsListViewModelInput {

    func viewDidLoad() {
        connectToServer()
    }

    func presentAlertController(presenter: TransitionHandler) {
        let tryAgainAction = UIAlertAction(title: texts(.alertActionTitle),
                                           style: .default) { [weak self] _ in
            self?.connectToServer()
        }
        coordinator.presentAlertController(style: .alert,
                                           title: texts(.alertTitle),
                                           message: texts(.alertMessage),
                                           actions: [tryAgainAction],
                                           presenter: presenter)
    }

    func filterUsers(with name: String) {
        fetchResultsController.fetchRequest.predicate = NSPredicate(format: "receiver.name BEGINSWITH %@", name)
        do {
            try fetchResultsController.performFetch()
            chatsCollectionShouldReload.accept(nil)
        } catch {
            print(error)
        }
    }

    func setupDefaultChatList() {
        fetchResultsController.fetchRequest.predicate = NSPredicate(format: "id != nil")
        do {
            try fetchResultsController.performFetch()
            chatsCollectionShouldReload.accept(nil)
        } catch {
            print(error)
        }
    }

    func setupChatCellNodeDelegate(with delegate: ChatCellNodeDelegate?,
                                   indexPath: IndexPath) {
        guard let delegate = delegate else { return }
        let chat = fetchResultsController.object(at: indexPath)
        guard let id = chat.id else { return }

        storageManager.fetchUser(chatID: id, from: .main)
            .subscribe { [palette, fonts] user in
                guard let user = user else { return }
                delegate.setupUser(with: user,
                                   color: palette(.chatNameCellColor),
                                   font: fonts(.cellMessageUserFont))
            }
            .disposed(by: bag)

        guard let avatarURL = chat.receiver?.avatarURL else { return }

        imageCacheManager.fetchImage(urlString: avatarURL)
            .subscribe { result in
                switch result {
                case .success(let image):
                    delegate.setupChatIcon(with: image)
                case .failure: return
                }
            }
            .disposed(by: bag)
    }

    func removeChat(at indexPath: IndexPath) -> Single<Any?> {
        let chat = fetchResultsController.object(at: indexPath)
        return storageManager.remove(chat: chat)
    }

    private func connectToServer() {
        webSocketsFacade.setupConnectionWith(userID: user.id) { [weak self] in
            self?.showAlert.accept(nil)
        }
    }

    // MARK: - Navigation
    func presentNewChatViewController(presenterVC: TransitionHandler) {
        coordinator.presentNewChatViewController(presenter: presenterVC)
    }

    func pushChatViewController(chat indexPath: IndexPath, presenterVC: TransitionHandler) {
        let chat = fetchResultsController.object(at: indexPath)
        guard let receiverUser = chat.receiver else { return }
        coordinator.pushChatViewController(receiverUser: ChatUser(coreDataUser: receiverUser),
                                           presenterVC: presenterVC)
    }

    func pushSettingsViewController(presenterVC: TransitionHandler) {
        coordinator.pushSettingsViewController(chatUser: user,
                                               presenter: presenterVC)
    }
}

// MARK: - extension + ChatsListViewModelOutput -
extension ChatsListViewModel: ChatsListViewModelOutput {

    func getChatCellModel(for indexPath: IndexPath) -> ChatCellModel? {
        let chat = fetchResultsController.object(at: indexPath)
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        guard let message = chat.messages?.sortedArray(using: [sortDescriptor]).first as? CDMessage else { return nil }

        return ChatCellModel(messageText: message.text ?? "",
                             messageDate: message.date,
                             baseFont: fonts(.cellMessageBaseFont))
    }
}
