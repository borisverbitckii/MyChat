//
//  MessagesFlowCoordinator.swift
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

protocol ChatsFlowProtocol {
    func joinPrivateRoom(chatID: String,
                         receiverUserID: String,
                         completion: @escaping (Result<Any?, Error>) -> Void)
}

protocol MessagesFlowProtocol {
    func sendMessage(messageText: String,
                     chatID: String,
                     senderID: String,
                     receiverID: String,
                     completion: @escaping (Result<Any?, Error>) -> Void)
}

protocol WebSocketConnector {
    func closeConnection()
}

final class WebSocketsFlowFacade: NSObject {

    // MARK: Private properties
    private lazy var operationQueue = OperationQueue()
    private lazy var bag = DisposeBag()

    private let webSocketsConnector: WebSocketsConnectorProtocol
    private let storageManager: StorageManagerProtocol

    // MARK: Init
    init(webSocketsConnector: WebSocketsConnectorProtocol,
         storageManager: StorageManagerProtocol) {
        self.webSocketsConnector = webSocketsConnector
        self.storageManager = storageManager

        super.init()

        webSocketsConnector.rawMessageStringObserver
            .subscribe { [operationQueue] rawMessageString in

                let context = storageManager.backgroundContextForSaving
                guard let context = context else { return }

                guard let messages = rawMessageString.decode(with: context) else { return }

                for message in messages {
                    // Если прилетает системное сообщение, удаляем его из контекста
                    if message.action != .sendMessageAction {
                        context.delete(message)
                    }

                    // Сервер отправляем отправленный клиентом сообщения обратно, игнорируем их
                    if message.sender?.id == AuthManager.currentUser?.uid {
                        continue
                    }
                    switch message.action {
                    case .sendMessageAction:
                        let saveMessageOperation = SaveMessageOperation(message: message,
                                                                        storageManager: storageManager)
                        operationQueue.addOperation(saveMessageOperation)
                    case .userJoinedAction:
                        let showUserOnlineOperation = ShowUserOnlineOperation(message: message,
                                                                              storageManager: storageManager)
                        operationQueue.addOperation(showUserOnlineOperation)
                    case .userLeftAction:
                        let showUserOfflineOperation = ShowUserOfflineOperation(message: message,
                                                                                storageManager: storageManager)
                        operationQueue.addOperation(showUserOfflineOperation)
                    case .leaveRoomAction:
                        break // TODO: Обработать
                    case .roomJoinedAction:
                        break // TODO: Обработать
                    default: break
                    }
                }
            } onError: { error in
                print(error) // TODO: Обработать
            }
            .disposed(by: bag)
    }

    func setupConnectionWith(userID: String) {
        webSocketsConnector.setUserID(userID: userID)
        webSocketsConnector.setURLSessionWebSocketsDelegate(with: self)
    }
}

// MARK: - extension + MessagesFlowCoordinatorProtocol -
extension WebSocketsFlowFacade: MessagesFlowProtocol {

    func sendMessage(messageText: String,
                     chatID: String,
                     senderID: String,
                     receiverID: String,
                     completion: @escaping (Result<Any?, Error>) -> Void) {
        let sendOperation = SendMessageOperation(messageText: messageText,
                                                 chatID: chatID,
                                                 senderID: senderID,
                                                 receiverID: receiverID,
                                                 storageManager: storageManager,
                                                 webSocketsConnector: webSocketsConnector,
                                                 completion: completion)
        operationQueue.addOperation(sendOperation)
    }
}

// MARK: - extension + ChatsFlowCoordinator -
extension WebSocketsFlowFacade: ChatsFlowProtocol {
    func joinPrivateRoom(chatID: String,
                         receiverUserID: String,
                         completion: @escaping (Result<Any?, Error>) -> Void) {
        let joinPrivateRoomOperation = JoinPrivateRoomOperation(chatID: chatID,
                                                                receiverUserID: receiverUserID,
                                                                storageManager: storageManager,
                                                                webSocketsConnector: webSocketsConnector,
                                                                completion: completion)
        operationQueue.addOperation(joinPrivateRoomOperation)
    }
}

// MARK: - extension + URLSessionWebSocketDelegate -
extension WebSocketsFlowFacade: URLSessionWebSocketDelegate {

    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didOpenWithProtocol protocol: String?) {
        Logger.log(to: .info, message: "Открыто подключение к web socket")
    }

    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
                    reason: Data?) {
        Logger.log(to: .info, message: "Подключение к web socket закрыто")
    }
}

extension WebSocketsFlowFacade: WebSocketConnector {
    func closeConnection() {
        webSocketsConnector.closeConnection()
    }
}
