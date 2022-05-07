//
//  BaseSendMessageOperation.swift
//  MyChat
//
//  Created by Boris Verbitsky on 06.05.2022.
//

import Models
import RxSwift
import Services
import Messaging
import Foundation

final class SendMessageOperation: BaseSendMessageOperation {

    // MARK: Private properties
    private let messageText: String
    private let chatID: String
    private let senderID: String

    // MARK: Init
    init(messageText: String,
         chatID: String,
         senderID: String,
         storageManager: StorageManagerProtocol,
         webSocketsConnector: WebSocketsConnectorProtocol,
         completion: @escaping (Result<Any?, Error>) -> Void) {
        self.messageText = messageText
        self.chatID = chatID
        self.senderID = senderID

        super.init(webSocketsConnector: webSocketsConnector,
                   storageManager: storageManager,
                   completion: completion)
    }

    // MARK: Override methods
    override func start() {
        // TODO: Залогировать
        let context = storageManager.backgroundContextNotForSaving

        storageManager.fetchChat(id: chatID, from: context)
            .subscribe { [weak self] chat in
                guard let self = self else { return }

                let room = self.storageManager.createRoom(id: self.chatID, in: context)
                let sender = self.storageManager.createSender(id: self.senderID, in: context)
                let message = self.storageManager.createMessage(action: .sendMessageAction,
                                                                text: self.messageText,
                                                                room: room,
                                                                sender: sender,
                                                                in: context)

                self.webSocketsConnector.executeWebSocketOperation(message: message)
                    .subscribe { _ in
                        self.completion(.success(nil))
                    } onFailure: { error in
                        self.completion(.failure(error))
                    }
                    .disposed(by: self.bag)

            } onFailure: { [completion] error in
                completion(.failure(error))
            }
            .disposed(by: bag)
    }
}
