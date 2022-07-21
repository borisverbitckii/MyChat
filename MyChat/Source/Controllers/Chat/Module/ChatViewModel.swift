//
//  ChatViewModel.swift
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

protocol ChatViewModelProtocol {
    var input: ChatViewModelInput { get }
    var output: ChatViewModelOutput { get }
}

protocol ChatViewModelInput {
    func checkIsUserOnline(presenter: TransitionHandler)
    func setupSender()
    func sendMessage(with text: String)
}

protocol  ChatViewModelOutput {
    var receiverUserName: BehaviorRelay<String> { get }
    var messageCollectionViewShouldReload: PublishRelay<Any?> { get }
    var fetchResultsController: NSFetchedResultsController<CDMessage>? { get }

    // UI
    var textfieldBackgroundColor: BehaviorRelay<UIColor> { get }
    var receiverUserIcon: PublishRelay<UIImage?> { get }
    var sendButtonColor: BehaviorRelay<UIColor> { get }
    var viewControllerBackgroundColor: BehaviorRelay<UIColor> { get }
    var userNameFont: UIFont { get }
    var toolBarPlaceholder: String { get }
    var toolBarPlaceholderFont: UIFont { get }

    func getCellModel() -> MessageCellModel
}

final class ChatViewModel {

    // MARK: Public properties
    var input: ChatViewModelInput { return self }
    var output: ChatViewModelOutput { return self }

    let receiverUser: ChatUser
    let fetchResultsController: NSFetchedResultsController<CDMessage>?

    // UI
    let textfieldBackgroundColor: BehaviorRelay<UIColor>
    let receiverUserIcon = PublishRelay<UIImage?>()
    let receiverUserName: BehaviorRelay<String>
    let sendButtonColor: BehaviorRelay<UIColor>
    let viewControllerBackgroundColor: BehaviorRelay<UIColor>
    let userNameFont: UIFont
    let toolBarPlaceholder: String
    let toolBarPlaceholderFont: UIFont

    let messageCollectionViewShouldReload = PublishRelay<Any?>()

    // MARK: Private properties
    private let coordinator: CoordinatorProtocol
    private let storageManager: StorageManagerProtocol
    private let imageCacheManager: ImageCacheManagerProtocol
    private let webSocketsFacade: WebSocketsFlowFacade

    private lazy var bag = DisposeBag()

    private var phoneUser: ChatUser?
    private var chatID: String?

    private let texts: (ChatViewControllerTexts) -> String
    private let palette: (ChatViewControllerPalette) -> UIColor
    private let fonts: (ChatViewControllerFonts) -> UIFont

    // MARK: - Init
    init(receiverUser: ChatUser,
         coordinator: CoordinatorProtocol,
         webSocketsFacade: WebSocketsFlowFacade,
         storageManager: StorageManagerProtocol,
         imageCacheManager: ImageCacheManagerProtocol,
         texts: @escaping (ChatViewControllerTexts) -> String,
         palette: @escaping (ChatViewControllerPalette) -> UIColor,
         fonts: @escaping (ChatViewControllerFonts) -> UIFont) {
        self.receiverUser = receiverUser

        self.webSocketsFacade = webSocketsFacade
        self.coordinator = coordinator
        self.storageManager = storageManager
        self.imageCacheManager = imageCacheManager

        self.texts = texts
        self.palette = palette
        self.fonts = fonts

        /// Цвета
        self.sendButtonColor = BehaviorRelay<UIColor>(value: palette(.chatViewControllerSendButtonColor))
        self.textfieldBackgroundColor = BehaviorRelay<UIColor>(value: palette(.chatViewControllerTextFieldBackgroundColor))
        self.viewControllerBackgroundColor = BehaviorRelay<UIColor>(value: palette(.chatViewControllerBackgroundColor))

        /// Текст
        self.receiverUserName = BehaviorRelay<String>(value: receiverUser.name)
        self.toolBarPlaceholder = texts(.toolBarPlaceholder)

        /// Шрифт
        self.userNameFont = fonts(.userName)
        self.toolBarPlaceholderFont = fonts(.toolBarPlaceholder)

        let phoneUser = AuthManager.currentUser
        self.phoneUser = ChatUser(id: phoneUser?.uid ?? "",
                                  name: phoneUser?.displayName ?? "-",
                                  email: phoneUser?.email ?? "-",
                                  avatarURL: phoneUser?.photoURL?.absoluteString ?? "")
        let chatID = ChatIDGenerator.generateChatID(phoneUserID: phoneUser?.uid ?? "",
                                                    targetUserID: receiverUser.id)
        self.chatID = chatID
        self.fetchResultsController = storageManager.getMessagesFetchResultsController(chatID: chatID)

        /// Подписка на изменения темы пользователя для автоматического обновления цвета
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(shouldUpdateColors),
                                               name: NSNotification.shouldUpdatePalette,
                                               object: nil)

        /// Вход в чатрум для начала общения
        webSocketsFacade.joinPrivateRoom(chatID: chatID,
                                         receiverUserID: receiverUser.id) { result in
            switch result {
            case .success:
                Logger.log(to: .info, message: "Успешно зашел в комнату с id \(chatID)")
            case .failure: break
            }
        }
    }

    // MARK: OBJC private methods
    /// Обновление ui после изменения темы телефона
    @objc private func shouldUpdateColors() {
        sendButtonColor.accept(palette(.chatViewControllerSendButtonColor))
        messageCollectionViewShouldReload.accept(nil)
    }
}

// MARK: - extension + ChatViewModelProtocol
extension ChatViewModel: ChatViewModelProtocol {

}

// MARK: - extension + ChatViewModelInputProtocol
extension ChatViewModel: ChatViewModelInput {

    func checkIsUserOnline(presenter: TransitionHandler) {
        let dismissAction = UIAlertAction(title: texts(.alertActionTitle),
                                          style: .default) { _ in
            presenter.popViewController()
        }
        if !webSocketsFacade.onlineUsers.contains(receiverUser.id) {
            coordinator.presentAlertController(style: .alert,
                                               title: texts(.alertTitle),
                                               message: texts(.alertMessage),
                                               actions: [dismissAction],
                                               presenter: presenter)
        }
    }

    func setupSender() {
        guard  let imageURLString = receiverUser.avatarURL else { return }
        imageCacheManager.fetchImage(urlString: imageURLString)
            .subscribe { [receiverUserIcon] image in
                guard let image = image else {
                    let placeholderImage = UIImage(named: "userImagePlaceholder")?.withRenderingMode(.alwaysTemplate)
                    receiverUserIcon.accept(placeholderImage)
                    return
                }
                receiverUserIcon.accept(image)
            } onFailure: { [receiverUserIcon] _ in
                receiverUserIcon.accept(nil)
            }
            .disposed(by: bag)
    }

    func sendMessage(with text: String) {
        /// Необходимо для того, чтобы обновлять соединение, если пользователь перезашел после бэкграунда
        webSocketsFacade.joinPrivateRoom(chatID: chatID ?? "",
                                         receiverUserID: receiverUser.id) { _ in }

        guard let chatID = chatID,
              let phoneUser = phoneUser else { return }
        if text == "" { return }

        let request = CDChatUser.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", receiverUser.id)

        let userCount = storageManager.checkObjectCount(request: request)

        if userCount == 0 || userCount == nil {
            storageManager.saveUser(with: receiverUser)
                .subscribe()
                .disposed(by: bag)
        }

        webSocketsFacade.sendMessage(messageText: text,
                                            chatID: chatID,
                                            sender: phoneUser,
                                            receiver: receiverUser) { result in
            switch result {
            case .success:
                Logger.log(to: .info, message: "Сообщение отправлено и сохранено в чат, текст `\(text)`")
            case .failure: break
            }
        }
    }
}

// MARK: - extension + ChatViewModelOutputProtocol
extension ChatViewModel: ChatViewModelOutput {

    func getCellModel() -> MessageCellModel {
        MessageCellModel(baseFont: fonts(.messageText),
                         timeFont: fonts(.time),
                         messageBubleBackgroundColor: palette(.chatViewControllerMessageCellColor))
    }
}
