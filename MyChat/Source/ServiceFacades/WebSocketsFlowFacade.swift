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
                         completion: @escaping (Result<Any?, Error>) -> Void)
}

protocol MessagesFlowProtocol {
    func sendMessage(messageText: String,
                     chatID: String,
                     senderID: String,
                     completion: @escaping (Result<Any?, Error>) -> Void)
}

final class WebSocketsFlowFacade: NSObject {

    // MARK: Private properties
    private lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    private lazy var bag = DisposeBag()

    private let webSocketsConnector: WebSocketsConnectorProtocol
    private let storageManager: StorageManagerProtocol

    // MARK: Init
    init(webSocketsConnector: WebSocketsConnectorProtocol,
         storageManager: StorageManagerProtocol) {
        self.webSocketsConnector = webSocketsConnector
        self.storageManager = storageManager

        super.init()
        webSocketsConnector.setURLSessionWebSocketsDelegate(with: self)

        webSocketsConnector.rawMessageStringObserver
            .subscribe { [operationQueue] rawMessageString in

                let context = storageManager.backgroundContextForSaving
                guard let messages = rawMessageString.decode(with: context) else { return }

                for message in messages {
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
    }

    // FetchResultsControllers
    func getChatsFetchResultsController() -> NSFetchedResultsController<Chat> {
        let request = Chat.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        request.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        return storageManager.getFetchResultsController(with: request)
    }

    func getMessagesFetchResultsController(chatID: String) -> NSFetchedResultsController<Message> {
        let request = Message.fetchRequest()
        request.predicate = NSPredicate(format: "chat.id == %@", chatID)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return storageManager.getFetchResultsController(with: request)
    }
}

// MARK: - extension + MessagesFlowCoordinatorProtocol -
extension WebSocketsFlowFacade: MessagesFlowProtocol {

    func sendMessage(messageText: String,
                     chatID: String,
                     senderID: String,
                     completion: @escaping (Result<Any?, Error>) -> Void) {
        let sendOperation = SendMessageOperation(messageText: messageText,
                                                 chatID: chatID,
                                                 senderID: senderID,
                                                 storageManager: storageManager,
                                                 webSocketsConnector: webSocketsConnector,
                                                 completion: completion)
        operationQueue.addOperation(sendOperation)
    }
}

// MARK: - extension + ChatsFlowCoordinator -
extension WebSocketsFlowFacade: ChatsFlowProtocol {
    func joinPrivateRoom(chatID: String, completion: @escaping (Result<Any?, Error>) -> Void) {
        let joinPrivateRoomOperation = JoinPrivateRoomOperation(chatID: chatID,
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
