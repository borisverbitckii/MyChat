//
//  SaveMessageOperation.swift
//  MyChat
//
//  Created by Boris Verbitsky on 05.05.2022.
//

import Logger
import Models
import RxSwift
import Services
import Foundation
import CoreData

final class SaveMessageOperation: BaseReceivedMessageOperation {

    // MARK: Private properties
    private let remoteDataBaseManager: RemoteDataBaseManagerProtocol

    // MARK: Init
    init(message: ReceivedMessage,
         storageManager: StorageManagerProtocol,
         remoteDataBaseManager: RemoteDataBaseManagerProtocol) {
        self.remoteDataBaseManager = remoteDataBaseManager
        super.init(message: message,
                   storageManager: storageManager)
    }

    // MARK: Override methods
    override func start() {
        guard let context = storageManager.backgroundContextForSaving else { return }

        /// Проверка на наличие уже существующего юзера
        storageManager.fetchUser(chatID: originalMessage.target?.id ?? "", from: .custom(context))
            .subscribe(onSuccess: { [weak self, originalMessage, context] user in
                var finalSender: CDChatUser?
                if let sender = user {
                    finalSender = sender
                } else {
                    /// Создание нового пользователя
                    finalSender = CDChatUser(context: context)
                    if let sender = originalMessage.sender {
                        /// Выгрузка данных о пользователе из удаленной БД
                        _ = self?.remoteDataBaseManager.fetchUser(fetchType: .all, id: sender.id)
                            .subscribe { user in
                                if let user = user {
                                    finalSender?.setup(with: user)
                                    /// Сохранение нового пользователя
                                    self?.storageManager.saveContext(with: context) { result in
                                        switch result {
                                        case .success:
                                            guard let finalSender = finalSender else { return }
                                            guard let message = self?.setupMessage(context: context) else { return }

                                            /// Поиск/создание чата
                                            self?.findChat(messageToSave: message,
                                                           sender: finalSender,
                                                           context: context)
                                        default: break
                                        }
                                    }
                                }
                            }
                    }
                    return
                }

                guard let finalSender = finalSender else { return }
                guard let message = self?.setupMessage(context: context) else { return }

                /// Поиск/создание чата
                self?.findChat(messageToSave: message,
                               sender: finalSender,
                               context: context)
            })
            .disposed(by: bag)
    }

    // MARK: Private methods
    /// Настройка нового сообщения относительно пришедшей информации
    /// - Returns: CoreData Message
    private func setupMessage(context: NSManagedObjectContext) -> CDMessage {
        let message = CDMessage(context: context)
        message.setup(with: originalMessage)
        return message
    }

    /// Поиск чата в БД или создание нового.
    /// - Parameters:
    ///   - id: id чата
    ///   - messageToSave: сообщение для сохранения
    ///   - sender: отправитель
    ///   - context: контекст CoreData
    private func findChat(messageToSave: CDMessage,
                          sender: CDChatUser,
                          context: NSManagedObjectContext) {
        storageManager.fetchChat(chatID: originalMessage.target?.id ?? "",
                                 from: context)
        .subscribe { [weak self, storageManager, originalMessage] chat in
            if let chat = chat {
                chat.addToMessages(messageToSave)
                chat.lastMessageDate = Date()
                storageManager.saveContext(with: context,
                                           completion: nil)
            } else {
                self?.createNewChat(chatID: originalMessage.target?.id ?? "",
                                    message: messageToSave,
                                    sender: sender,
                                    in: context)
            }
        }
        .disposed(by: bag)
    }

    private func createNewChat(chatID: String,
                               message: CDMessage,
                               sender: CDChatUser,
                               in context: NSManagedObjectContext) {
        let chat = storageManager.createChat(chatID: chatID,
                                             receiverUser: .coreDataUser(sender),
                                             in: context)
        chat.addToMessages(message)
        storageManager.saveContext(with: context, completion: nil)
    }
}
