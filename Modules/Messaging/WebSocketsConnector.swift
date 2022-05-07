//
//  WebSocketsConnector.swift
//  Messaging
//
//  Created by Boris Verbitsky on 22.04.2022.
//

import Logger
import Models
import RxSwift
import RxRelay
import Foundation

public protocol WebSocketsConnectorProtocol {
    var rawMessageStringObserver: PublishRelay<String> { get }
    var userID: String? { get }
    func setUserID(userID: String)
    func setURLSessionWebSocketsDelegate(with delegate: URLSessionWebSocketDelegate)
    func executeWebSocketOperation(message: Message) -> Single<Any?>
}

public class WebSocketsConnector {

    // MARK: Public properties
    public var userID: String?
    public lazy var rawMessageStringObserver = PublishRelay<String>()

    // MARK: Private properties
    private lazy var url = URL(string: "ws://localhost:8080?uuid=\(userID ?? "")")!
    private var urlSession: URLSession?

    private lazy var webSocketTask: URLSessionWebSocketTask? = {
        guard let urlSession = urlSession else { return nil }
        let request = URLRequest(url: url)
        let task = urlSession.webSocketTask(with: url)
        return task
    }()

    // MARK: Init
    public init() {}

    // MARK: Private methods
    private func connectToServer() {
        webSocketTask?.resume()
        runReceiveMessageLoop()
    }

    private func runReceiveMessageLoop() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let result):
                Logger.log(to: .info, message: "Получено сообщение по web socket")
                switch result {
                case .string(let string):
                    self?.rawMessageStringObserver.accept(string)
                case .data:
                    break
                @unknown default:
                    break
                }
                self?.runReceiveMessageLoop()
            case .failure(let error):
                Logger.log(to: .error,
                           message: "Не удалось загрузить сообщение",
                           error: error)
            }
        }
    }

    private func encodeMessageToData(message: Message, result: @escaping (Result<Any?, Error>) -> Void) -> Data? {
        do {
            return try JSONEncoder().encode(message)
        } catch {
            Logger.log(to: .error, message: "Не удалось кодировать Message в Data", error: error)
            result(.failure(error))
            return nil
        }
    }
}

// MARK: - extension + MessengerProtocol -
extension WebSocketsConnector: WebSocketsConnectorProtocol {

    /// Установка делегата для URLSession
    ///
    /// Требуется для инициализации
    /// - Parameter delegate: Делегат URLSession
    public func setURLSessionWebSocketsDelegate(with delegate: URLSessionWebSocketDelegate) {
        urlSession = URLSession(configuration: .default, delegate: delegate, delegateQueue: OperationQueue())
    }

    /// Установка id пользователя телефона, чтобы отправлять этот id на сервер
    /// и по нему можно было его найти
    ///
    /// - Parameter userID: ID пользователя телефона
    public func setUserID(userID: String) {
        self.userID = userID
        connectToServer()
    }

    public func executeWebSocketOperation(message: Message) -> Single<Any?> {
        Single<Any?>.create { [weak self] obs in

            guard let webSocketTask = self?.webSocketTask else {
                Logger.log(to: .error, message: "URLSession для web sockets еще не инициализирована")
                return Disposables.create()
            }
            guard let messageData = self?.encodeMessageToData(message: message,
                                                              result: obs) else {
                   return Disposables.create()
               }

            webSocketTask.send(.data(messageData)) { error in
                if let error = error {
                    Logger.log(to: .error,
                               message: "Не удалось отправить сообщение по web socket",
                               error: error)
                    obs(.failure(error))
                    return
                }
                Logger.log(to: .info, message: "Отправлено сообщение по web sockets")
                obs(.success(nil))
            }
            return Disposables.create()
        }
        .observe(on: MainScheduler.instance)
    }

}
