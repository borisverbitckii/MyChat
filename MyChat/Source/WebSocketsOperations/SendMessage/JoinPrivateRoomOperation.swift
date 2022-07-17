//
//  JoinPrivateRoomOperation.swift
//  MyChat
//
//  Created by Boris Verbitsky on 06.05.2022.
//

import Models
import Logger
import RxSwift
import Services
import Messaging
import Foundation

/*
 Операция для того, чтобы войти в нужную комнату чата на сервере
 С момента входа пользователь телефона начинает получать из комнаты сообщения
 */

final class JoinPrivateRoomOperation: BaseSendMessageOperation {

    // MARK: Private properties
    private let chatID: String
    private let receiverUserID: String

    // MARK: Init
    init(chatID: String,
         receiverUserID: String,
         storageManager: StorageManagerProtocol,
         webSocketsConnector: WebSocketsConnectorProtocol,
         completion: @escaping (Result<Any?, Error>) -> Void) {
        self.chatID = chatID
        self.receiverUserID = receiverUserID

        super.init(webSocketsConnector: webSocketsConnector,
                   storageManager: storageManager,
                   completion: completion)
    }

    // MARK: Override methods
    override func start() {
        guard let context = storageManager.backgroundContextNotForSaving else { return }
        let sender = storageManager.createChatUser(id: "", in: context)
        let room = storageManager.createTarget(id: chatID, in: context)
        let message = storageManager.createMessage(action: .joinRoomPrivateAction,
                                                   position: .noPosition,
                                                   text: receiverUserID,
                                                   target: room,
                                                   sender: sender,
                                                   in: context)

        webSocketsConnector.executeWebSocketOperation(message: message)
            .subscribe { [completion] _ in
                completion(.success(nil))
                Logger.log(to: .info,
                           message: "Выполнен вход в чат с id \(room.id)")
            } onFailure: { [completion] error in
                completion(.failure(error))
            }
            .disposed(by: bag)
    }
}
