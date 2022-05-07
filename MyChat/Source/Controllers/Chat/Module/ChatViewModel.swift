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
import Messaging

protocol ChatViewModelProtocol {
    var input: ChatViewModelInput { get }
    var output: ChatViewModelOutput { get }
}

protocol ChatViewModelInput {
    func sendMessage(with text: String)
    func getMessage(for index: Int) -> Message
    func getMessagesCount() -> Int
}

protocol  ChatViewModelOutput {
    var messageCollectionViewShouldReload: PublishRelay<Any?> { get }
}

final class ChatViewModel {

    // MARK: Public properties
    var input: ChatViewModelInput { return self }
    var output: ChatViewModelOutput { return self }

    public let chat: Chat

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

    // MARK: - Init
    init(chat: Chat,
         coordinator: CoordinatorProtocol,
         messagesFlowCoordinator: MessagesFlowProtocol) {
        self.chat = chat
        self.coordinator = coordinator
        self.messagesFlowCoordinator = messagesFlowCoordinator
    }
}

// MARK: - extension + ChatViewModelProtocol
extension ChatViewModel: ChatViewModelProtocol {

}

// MARK: - extension + ChatViewModelInputProtocol
extension ChatViewModel: ChatViewModelInput {

    func sendMessage(with text: String) {
//        messagingFlowManager.sendMessage(with: text, to: chat.targetUserUUID)
//            .subscribe()
//            .disposed(by: bag)
//
//        messagesFlowCoordinator.sendMessage(messageText: text, chatID: chat.id, senderID: chat.sender, completion: <#T##(Result<Any?, Error>) -> Void#>)
    }

    func getMessage(for index: Int) -> Message {
        messages[index]
    }

    func getMessagesCount() -> Int {
        messages.count
    }
}

// MARK: - extension + ChatViewModelOutputProtocol
extension ChatViewModel: ChatViewModelOutput {

}

//// MARK: - extension + ChatViewModelOutputProtocol -
//extension ChatViewModel: MessagesReceiverProtocol {
//    func showMessage(_ message: Message) {
//        messages.insert(message, at: 0)
//    }
//}
