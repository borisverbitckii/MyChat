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

/*
 Операция для отправки и автоматического сохранения в БД сообщения
 */

final class SendMessageOperation: BaseSendMessageOperation {

    // MARK: Private properties
    private let messageText: String
    private let chatID: String
    private let sender: ChatUser
    private let receiver: ChatUser

    // MARK: Init
    init(messageText: String,
         chatID: String,
         sender: ChatUser,
         receiver: ChatUser,
         storageManager: StorageManagerProtocol,
         webSocketsConnector: WebSocketsConnectorProtocol,
         completion: @escaping (Result<Any?, Error>) -> Void) {
        self.messageText = messageText
        self.chatID = chatID
        self.sender = sender
        self.receiver = receiver

        super.init(webSocketsConnector: webSocketsConnector,
                   storageManager: storageManager,
                   completion: completion)
    }

    // MARK: Override methods
    override func start() {
        guard let context = storageManager.backgroundContextForSaving else { return }
        let target = storageManager.createTarget(id: chatID, in: context)

        let sender = CDChatUser(context: context)
        sender.setup(with: self.sender)
        let message = storageManager.createMessage(action: .sendMessageAction,
                                                   position: .right,
                                                   text: messageText,
                                                   target: target,
                                                   sender: sender,
                                                   in: context)
        Logger.log(to: .info,
                   message: "Сообщение создано и будет отправлено, id: \(String(describing: message.id))")
        fetchChat(chatID: chatID,
                  message: message,
                  context: context)
        executeWebSocketOperation(message: message)
    }

    // MARK: Private methods
    /// Поиск или создание чата
    /// - Parameters:
    ///   - chatID: id чата
    ///   - message: сообщение
    ///   - context: контекст CoreData
    private func fetchChat(chatID: String,
                           message: CDMessage,
                           context: NSManagedObjectContext) {
        /// Поиск/создание чата
        storageManager.fetchChat(chatID: chatID, from: context)
            .subscribe { [weak self] chat in
                if let chat = chat {
                    chat.addToMessages(message)
                    chat.lastMessageDate = Date()
                    self?.storageManager.saveContext(with: context, completion: nil)
                } else {
                    guard let chatID = self?.chatID else { return }
                    self?.createNewChat(chatID: chatID,
                                        message: message,
                                        in: context)
                }
            } onFailure: { [weak self] _ in
                guard let chatID = self?.chatID else { return }
                self?.createNewChat(chatID: chatID,
                                    message: message,
                                    in: context)
            }
            .disposed(by: bag)
    }

    private func executeWebSocketOperation(message: CDMessage) {
        self.webSocketsConnector.executeWebSocketOperation(message: message)
            .subscribe { [weak self] _ in
                self?.completion(.success(nil))
            } onFailure: { [weak self] error in
                self?.completion(.failure(error))
            }
            .disposed(by: self.bag)
    }

    /// Cоздание нового чата
    /// - Parameters:
    ///   - chatID: id чата
    ///   - message: сообщение
    ///   - context: контекст CoreData
    private func createNewChat(chatID: String,
                               message: CDMessage,
                               in context: NSManagedObjectContext) {
        let chat = storageManager.createChat(chatID: chatID,
                                             receiverUser: .chatUser(receiver),
                                             in: context)
        let receiver = CDChatUser(context: context)
        receiver.setup(with: self.receiver)
        chat.receiver = receiver
        chat.addToMessages(message)
        storageManager.saveContext(with: context, completion: nil)
    }
}
