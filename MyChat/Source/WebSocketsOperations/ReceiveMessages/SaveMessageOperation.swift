//
//  SaveMessageOperation.swift
//  MyChat
//
//  Created by Boris Verbitsky on 05.05.2022.
//

import Logger
import Models
import RxSwift
import Services
import Foundation

final class SaveMessageOperation: BaseReceivedMessageOperation {
    
    // MARK: Private properties
    private var completion: ((Result<Any?, Error>) -> Void)?

    // MARK: Init
    init(message: Message,
         storageManager: StorageManagerProtocol,
         completion: ((Result<Any?, Error>) -> Void)? = nil) {
        self.completion = completion
        super.init(message: message,
                   storageManager: storageManager)
    }

    // MARK: Override methods
    override func start() {
        // TODO: Залогировать
        if message.action == .sendMessageAction {
            if let roomID = message.room?.id {

                let context = storageManager.backgroundContextForSaving

                storageManager.fetchChat(id: roomID, from: context)
                    .subscribe { [completion, message] chat in
                        chat.addToMessages(message)

                        do {
                            try context.save()
                            completion?(.success(nil))
                        } catch {
                            Logger.log(to: .error, message: "Не удалось сохранить контекст core data", error: error)
                            completion?(.failure(error))
                        }
                    } onFailure: { [weak self, message] _ in
                        let chat = self?.storageManager.createChat(id: roomID,
                                                                   targetUserUUID: message.sender?.id ?? "",
                                                                   in: context)
                        chat?.addToMessages(message)

                        do {
                            try context.save()
                            self?.completion?(.success(nil))
                        } catch {
                            Logger.log(to: .error, message: "Не удалось сохранить контекст core data", error: error)
                            self?.completion?(.failure(error))
                        }
                    }
                    .disposed(by: bag)
            }
        }
    }
}
