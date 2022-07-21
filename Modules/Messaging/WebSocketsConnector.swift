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

/*

Коннектор для вебсокетов

Здесь происходит подключение, установка делегата, а также отправлка и получение информации
Обработка полученных сообщений происходит в WebSocketsFlowFacade

 */

public protocol WebSocketsConnectorProtocol {
    /// Обсервер для получаемой даты
    var rawMessageStringObserver: PublishRelay<String> { get }
    /// ID пользователя для идентификации на сервере
    var userID: String? { get }
    func setUserID(userID: String)
    func setURLSessionWebSocketsDelegate(with delegate: URLSessionWebSocketDelegate)
    func executeWebSocketOperation(message: CDMessage) -> Single<Any?>
    func closeConnection()
}

public class WebSocketsConnector {

    // MARK: Public properties
    public var userID: String? {
        didSet {
            url = URL(string: "ws://87.242.72.234:8081?uuid=\(userID ?? "")")
        }
    }
    public lazy var rawMessageStringObserver = PublishRelay<String>()

    // MARK: Private properties
    private var url: URL?
    private var urlSession: URLSession? {
        didSet {
            guard let urlSession = urlSession,
                  let url = url else { return }
            let task = urlSession.webSocketTask(with: url)
            webSocketTask = task
            connectToServer()
        }
    }

    private var webSocketTask: URLSessionWebSocketTask?
    private let lock = NSLock()

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
                    self?.lock.lock()
                    self?.rawMessageStringObserver.accept(string)
                    self?.lock.unlock()
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

    private func encodeMessageToData(message: CDMessage, result: @escaping (Result<Any?, Error>) -> Void) -> Data? {
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
        urlSession = URLSession(configuration: .default,
                                delegate: delegate,
                                delegateQueue: OperationQueue())
    }

    /// Установка id пользователя телефона, чтобы отправлять этот id на сервер
    /// и по нему можно было его найти
    ///
    /// - Parameter userID: ID пользователя телефона
    public func setUserID(userID: String) {
        self.userID = userID
    }

    public func executeWebSocketOperation(message: CDMessage) -> Single<Any?> {
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

    public func closeConnection() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        Logger.log(to: .info, message: "Иницииован разрыв соединения с сервером")
    }
}
