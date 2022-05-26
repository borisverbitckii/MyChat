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
    func sendMessage(with text: String)
}

protocol  ChatViewModelOutput {
    var messageCollectionViewShouldReload: PublishRelay<Any?> { get }
    var fetchResultsController: NSFetchedResultsController<Message>? { get }
}

final class ChatViewModel {

    // MARK: Public properties
    var input: ChatViewModelInput { return self }
    var output: ChatViewModelOutput { return self }

    let receiverUser: ChatUser
    private(set) var fetchResultsController: NSFetchedResultsController<Message>?

    var messageCollectionViewShouldReload = PublishRelay<Any?>()

    // MARK: Private properties
    private let coordinator: CoordinatorProtocol
    private let messagesFlowCoordinator: MessagesFlowProtocol

    private lazy var bag = DisposeBag()

    private lazy var messages = [Message]() {
        didSet {
            messageCollectionViewShouldReload.accept(nil)
        }
    }
    private var phoneUserID: String?
    private var chatID: String?

    // MARK: - Init
    init(receiverUser: ChatUser,
         coordinator: CoordinatorProtocol,
         webSocketsFacade: WebSocketsFlowFacade,
         storageManager: StorageManagerProtocol) {
        self.receiverUser = receiverUser
        self.coordinator = coordinator
        self.messagesFlowCoordinator = webSocketsFacade

        guard let phoneUserID = AuthManager.currentUser?.uid else { return }
        self.phoneUserID = phoneUserID
        let chatID = ChatIDGenerator.generateChatID(phoneUserID: phoneUserID, targetUserID: receiverUser.userID)
        self.chatID = chatID
        self.fetchResultsController = storageManager.getMessagesFetchResultsController(chatID: chatID)

        webSocketsFacade.joinPrivateRoom(chatID: chatID,
                                         receiverUserID: receiverUser.userID) { result in
            switch result {
            case .success:
                Logger.log(to: .info, message: "Успешно зашел в комнату с id \(chatID)")
            case .failure(let error):
                break
            }
        }
    }
}

// MARK: - extension + ChatViewModelProtocol
extension ChatViewModel: ChatViewModelProtocol {

}

// MARK: - extension + ChatViewModelInputProtocol
extension ChatViewModel: ChatViewModelInput {

    func sendMessage(with text: String) {
        guard let chatID = chatID,
                let phoneUserID = phoneUserID else { return }
        messagesFlowCoordinator.sendMessage(messageText: text,
                                            chatID: chatID,
                                            senderID: phoneUserID,
                                            receiverID: receiverUser.userID) { result in
            switch result {
            case .success:
                Logger.log(to: .info, message: "Сообщение отправлено и сохранено в чат")
            case .failure(let error):
                break
            }
        }
    }
}

// MARK: - extension + ChatViewModelOutputProtocol
extension ChatViewModel: ChatViewModelOutput {

}
