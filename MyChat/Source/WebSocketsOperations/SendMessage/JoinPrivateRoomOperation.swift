//
//  JoinPrivateRoomOperation.swift
//  MyChat
//
//  Created by Boris Verbitsky on 06.05.2022.
//

import Models
import RxSwift
import Services
import Messaging
import Foundation

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
        // TODO: Залогировать
        guard let context = storageManager.backgroundContextNotForSaving else { return }
        let room = storageManager.createRoom(id: chatID, in: context)
        let message = storageManager.createMessage(action: .joinRoomPrivateAction,
                                                   text: receiverUserID,
                                                   room: room,
                                                   sender: nil,
                                                   in: context)

        webSocketsConnector.executeWebSocketOperation(message: message)
            .subscribe { [completion] _ in
                completion(.success(nil))
            } onFailure: { [completion] error in
                completion(.failure(error))
            }
            .disposed(by: bag)
    }
}
