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

/*
Фасад для того, чтобы сразу сохранять сообщения в локальную БД.
Является делегатом для URLSession, которая отвечате за webSocket подключение
*/

protocol WebSocketsFlowFacadeProtocol {

    func sendMessage(messageText: String,
                     chatID: String,
                     sender: ChatUser,
                     receiver: ChatUser,
                     completion: @escaping (Result<Any?, Error>) -> Void)

    func closeConnection()
}

final class WebSocketsFlowFacade: NSObject {

    // MARK: Public properties
    /// Список пользователей, который онлайн
    var onlineUsers = Set<String>()

    // MARK: Private properties
    private lazy var operationQueue = OperationQueue()
    private lazy var bag = DisposeBag()

    private let webSocketsConnector: WebSocketsConnectorProtocol
    private let storageManager: StorageManagerProtocol

    private var errorClosure: (() -> Void)?

    private var isNotActive = false

    // MARK: Init
    init(webSocketsConnector: WebSocketsConnectorProtocol,
         remoteDataBaseManager: RemoteDataBaseManagerProtocol,
         storageManager: StorageManagerProtocol) {
        self.webSocketsConnector = webSocketsConnector
        self.storageManager = storageManager

        super.init()

        webSocketsConnector.rawMessageStringObserver
            .compactMap { rawMessageString in
                return rawMessageString.decode()
            }
            .subscribe { [weak self, operationQueue] messages in
                guard let messages = messages.element else { return }

                for message in messages {
                    // Сервер отправляем отправленный клиентом сообщения обратно, игнорируем их
                    if message.sender?.id == AuthManager.currentUser?.uid {
                        continue
                    }
                    switch message.action {
                    case .sendMessageAction:
                        let saveMessageOperation = SaveMessageOperation(message: message,
                                                                        storageManager: storageManager,
                                                                        remoteDataBaseManager: remoteDataBaseManager)
                        operationQueue.addOperation(saveMessageOperation)
                    case .userJoinedAction:
                        if let senderID = message.sender?.id {
                            self?.onlineUsers.insert(senderID)
                        }
                    case .userLeftAction:
                        if let senderID = message.sender?.id {
                            self?.onlineUsers.remove(senderID)
                        }
                    default: break
                    }
                }
            }
            .disposed(by: bag)
    }

    func setupConnectionWith(userID: String, errorClosure: @escaping () -> Void) {
        webSocketsConnector.setUserID(userID: userID)
        webSocketsConnector.setURLSessionWebSocketsDelegate(with: self)
        self.errorClosure = errorClosure
    }

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

// MARK: - extension + MessagesFlowCoordinatorProtocol -
extension WebSocketsFlowFacade: WebSocketsFlowFacadeProtocol {

    func sendMessage(messageText: String,
                     chatID: String,
                     sender: ChatUser,
                     receiver: ChatUser,
                     completion: @escaping (Result<Any?, Error>) -> Void) {
        let sendOperation = SendMessageOperation(messageText: messageText,
                                                 chatID: chatID,
                                                 sender: sender,
                                                 receiver: receiver,
                                                 storageManager: storageManager,
                                                 webSocketsConnector: webSocketsConnector,
                                                 completion: completion)
        operationQueue.addOperation(sendOperation)
    }

    func closeConnection() {
        webSocketsConnector.closeConnection()
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
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        guard let error = error else { return }
        Logger.log(to: .error,
                   message: "Не удалось установить подключение к web socket",
                   error: error)
        guard let errorClosure = errorClosure else { return }

        DispatchQueue.main.async {
            errorClosure()
        }
    }

    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
                    reason: Data?) {
        Logger.log(to: .info, message: "Подключение к web socket закрыто")
    }
}
