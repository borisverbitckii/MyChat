//
//  ViewModel.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

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
    func removeChat(at indexPath: IndexPath) -> Single<Any?>
    func presentNewChatViewController(presenterVC: TransitionHandler)
    func pushChatViewController(chat atIndexPath: IndexPath, presenterVC: TransitionHandler)
}

protocol ChatsListViewModelOutput {
    var fetchResultsController: NSFetchedResultsController<Chat> { get }
    var chatsCollectionShouldReload: PublishRelay<Any?> { get }

    // UI
    var viewControllerBackgroundColor: BehaviorRelay<UIColor> { get }
    var titleText: BehaviorRelay<String> { get }
    var titleFont: BehaviorRelay<UIFont> { get }
    var searchPlaceholder: BehaviorRelay<String> { get }
    var deleteButtonTitle: BehaviorRelay<String> { get }
}

final class ChatsListViewModel {

    // MARK: Public properties
    var input: ChatsListViewModelInput { return self }
    var output: ChatsListViewModelOutput { return self }

    var chatsCollectionShouldReload = PublishRelay<Any?>()

    private(set) var fetchResultsController: NSFetchedResultsController<Chat>

    // UI
    var viewControllerBackgroundColor: BehaviorRelay<UIColor>
    var titleText: BehaviorRelay<String>
    var titleFont: BehaviorRelay<UIFont>
    var searchPlaceholder: BehaviorRelay<String>
    var deleteButtonTitle: BehaviorRelay<String>

    // MARK: Private properties
    private let coordinator: CoordinatorProtocol
    private let chatsCoordinator: ChatsFlowProtocol
    private let remoteDataBaseManager: RemoteDataBaseManagerProtocol
    private let storageManager: StorageManagerProtocol

    private let fonts: (ChatsListViewControllerFonts) -> UIFont
    private let texts: (ChatsListViewControllerTexts) -> String
    private let palette: (ChatsListViewControllerPalette) -> UIColor

    private lazy var bag = DisposeBag()

    // MARK: Init
    init(user: ChatUser,
         coordinator: CoordinatorProtocol,
         webSocketsFacade: WebSocketsFlowFacade,
         storageManager: StorageManagerProtocol,
         remoteDataBaseManager: RemoteDataBaseManagerProtocol,
         fonts: @escaping (ChatsListViewControllerFonts) -> UIFont,
         texts: @escaping (ChatsListViewControllerTexts) -> String,
         palette: @escaping (ChatsListViewControllerPalette) -> UIColor) {
        self.coordinator = coordinator
        self.storageManager = storageManager
        self.remoteDataBaseManager = remoteDataBaseManager

        self.chatsCoordinator = webSocketsFacade
        webSocketsFacade.setupConnectionWith(userID: user.userID)
        self.fetchResultsController = storageManager.getChatsFetchResultsController()

        self.fonts = fonts
        self.texts = texts
        self.palette = palette

        // Настройка цветов
        let vcBackgroundColor = palette(.chatsListViewControllerBackgroundColor)
        self.viewControllerBackgroundColor = BehaviorRelay<UIColor>(value: vcBackgroundColor)

        // Настройка текстов
        self.titleText = BehaviorRelay<String>(value: texts(.title))
        self.searchPlaceholder = BehaviorRelay<String>(value: texts(.searchBarPlaceholder))
        self.deleteButtonTitle = BehaviorRelay<String>(value: texts(.deleteButtonTitle))

        // Настройка шрифтов
        let font = fonts(.empty) // TODO: - Убрать
        self.titleFont = BehaviorRelay<UIFont>(value: font)
    }
}

// MARK: - extension + ChatsListViewModelProtocol -
extension ChatsListViewModel: ChatsListViewModelProtocol {

}

// MARK: - extension + ChatsListViewModelInput -
extension ChatsListViewModel: ChatsListViewModelInput {

    func removeChat(at indexPath: IndexPath) -> Single<Any?> {
        let chat = fetchResultsController.object(at: indexPath)
        return storageManager.remove(chat: chat)
    }

    func presentNewChatViewController(presenterVC: TransitionHandler) {
        coordinator.presentNewChatViewController(presenter: presenterVC)
    }

    func pushChatViewController(chat atIndexPath: IndexPath, presenterVC: TransitionHandler) {
        let chat = fetchResultsController.object(at: atIndexPath)
        guard let targetUserUUID = chat.targetUserUUID else { return }
        remoteDataBaseManager.fetchUser(uuid: targetUserUUID)
            .subscribe { [coordinator] user in
                guard let user = user else { return }
                coordinator.pushChatViewController(receiverUser: user, presenterVC: presenterVC)
            } onFailure: { error in
                //TODO: Доделать
            }
            .disposed(by: bag)
    }
}

// MARK: - extension + ChatsListViewModelOutput -
extension ChatsListViewModel: ChatsListViewModelOutput {
}
