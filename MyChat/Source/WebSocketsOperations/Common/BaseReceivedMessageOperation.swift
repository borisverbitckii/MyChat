//
//  BaseReceivedMessageOperation.swift
//  MyChat
//
//  Created by Boris Verbitsky on 05.05.2022.
//

import Models
import RxSwift
import Services
import Foundation

class BaseReceivedMessageOperation: Operation {

    // MARK: Public properties
    final let originalMessage: ReceivedMessage
    final let storageManager: StorageManagerProtocol
    private(set) final lazy var bag = DisposeBag()

    // MARK: Init
    init(message: ReceivedMessage,
         storageManager: StorageManagerProtocol) {
        self.originalMessage = message
        self.storageManager = storageManager
        super.init()
    }
}
