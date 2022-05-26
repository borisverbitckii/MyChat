//
//  BaseSendMessageOperation.swift
//  MyChat
//
//  Created by Boris Verbitsky on 06.05.2022.
//

import Models
import Logger
import RxSwift
import Services
import CoreData
import Messaging
import Foundation

final class SendMessageOperation: BaseSendMessageOperation {

    // MARK: Private properties
    private let messageText: String
    private let chatID: String
    private let senderID: String
    private let receiverID: String

    // MARK: Init
    init(messageText: String,
         chatID: String,
         senderID: String,
         receiverID: String,
         storageManager: StorageManagerProtocol,
         webSocketsConnector: WebSocketsConnectorProtocol,
         completion: @escaping (Result<Any?, Error>) -> Void) {
        self.messageText = messageText
        self.chatID = chatID
        self.senderID = senderID
        self.receiverID = receiverID

        super.init(webSocketsConnector: webSocketsConnector,
                   storageManager: storageManager,
                   completion: completion)
    }

    // MARK: Override methods
    override func start() {
        // TODO: Залогировать
        guard let context = storageManager.backgroundContextForSaving else { return }

        let room = storageManager.createRoom(id: self.chatID, in: context)
        let sender = storageManager.createSender(id: self.senderID, in: context)
        let message = storageManager.createMessage(action: .sendMessageAction,
                                                   text: self.messageText,
                                                   room: room,
                                                   sender: sender,
                                                   in: context)

        storageManager.fetchChat(id: chatID, from: context)
            .subscribe { [weak self, completion] chat in
                if let chat = chat {
                    chat.addToMessages(message)
                    self?.storageManager.saveContext(with: context, completion: completion)
                } else {
                    guard let chatID = self?.chatID else { return }
                    self?.createNewChat(chatID: chatID,
                                        message: message,
                                        in: context)
                }
            } onFailure: { [weak self] _ in // TODO: Обработать ошибку сохранения сообщения
                guard let chatID = self?.chatID else { return }
                self?.createNewChat(chatID: chatID,
                                    message: message,
                                    in: context)
            }
            .disposed(by: bag)

        self.webSocketsConnector.executeWebSocketOperation(message: message)
            .subscribe { [weak self] _ in
                self?.completion(.success(nil))
            } onFailure: { [weak self] error in
                self?.completion(.failure(error))
            }
            .disposed(by: self.bag)
    }

    // MARK: Private methods
    private func createNewChat(chatID: String,
                               message: Message,
                               in context: NSManagedObjectContext) {
        let chat = storageManager.createChat(id: chatID,
                                             targetUserUUID: receiverID,
                                             in: context)
        chat.addToMessages(message)

        storageManager.saveContext(with: context, completion: completion)
    }
}
