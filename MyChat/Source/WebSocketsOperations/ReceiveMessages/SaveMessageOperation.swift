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
import CoreData

final class SaveMessageOperation: BaseReceivedMessageOperation {

    // MARK: Init
    override init(message: Message,
                  storageManager: StorageManagerProtocol) {
        super.init(message: message,
                   storageManager: storageManager)
    }

    // MARK: Override methods
    override func start() {
        // TODO: Залогировать
        if message.action == .sendMessageAction {
            if let roomID = message.room?.id {

                guard let context = message.managedObjectContext else { return }

                storageManager.fetchChat(id: roomID, from: context)
                    .subscribe { [weak self, message] chat in
                        if let chat = chat {
                            chat.addToMessages(message)
                            self?.storageManager.saveContext(with: context, completion: nil)
                        } else {
                            self?.createNewChat(id: roomID,
                                                in: context)
                        }
                    } onFailure: { [weak self] _ in
                        self?.createNewChat(id: roomID,
                                            in: context)
                    }
                    .disposed(by: bag)
            }
        }
    }

    // MARK: Private methods
    private func createNewChat(id: String,
                               in context: NSManagedObjectContext) {

        guard let context = message.managedObjectContext else { return }
        let chat = storageManager.createChat(id: id,
                                             targetUserUUID: message.sender?.id ?? "",
                                             in: context)
        chat.addToMessages(message)

        storageManager.saveContext(with: context, completion: nil)
    }
}
