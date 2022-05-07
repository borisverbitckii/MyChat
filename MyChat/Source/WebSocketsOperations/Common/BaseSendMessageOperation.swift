//
//  BaseSendMessageOperation.swift
//  MyChat
//
//  Created by Boris Verbitsky on 06.05.2022.
//

import RxSwift
import Services
import Messaging
import Foundation

class BaseSendMessageOperation: Operation {

    // MARK: Public properties
    private(set) final lazy var bag = DisposeBag()

    final let webSocketsConnector: WebSocketsConnectorProtocol
    final let storageManager: StorageManagerProtocol
    final let completion: (Result<Any?, Error>) -> Void

    init(webSocketsConnector: WebSocketsConnectorProtocol,
         storageManager: StorageManagerProtocol,
         completion: @escaping (Result<Any?, Error>) -> Void) {
        self.webSocketsConnector = webSocketsConnector
        self.storageManager = storageManager
        self.completion = completion
        super.init()
    }
}
