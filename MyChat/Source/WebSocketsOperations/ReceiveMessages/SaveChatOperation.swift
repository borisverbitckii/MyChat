//
//  SaveChatOperation.swift
//  MyChat
//
//  Created by Boris Verbitsky on 05.05.2022.
//

import Models
import Logger
import RxSwift
import Services
import Foundation

final class SaveChatOperation: BaseReceivedMessageOperation {
    
    // MARK: Private properties
    private let completion: (Result<Any?, Error>) -> Void

    // MARK: Init
    init(message: Message,
         storageManager: StorageManager, // TODO: Подкинуть протокол
         completion: @escaping (Result<Any?, Error>) -> Void) {
        self.completion = completion
        super.init(message: message,
                   storageManager: storageManager)
    }

    // MARK: Override methods
    override func start() {
        // TODO: Залогировать
        let context = storageManager.backgroundContextForSaving
        guard let roomID = message.room?.id else {
            let error = NSError(domain: "Отсутствует id чата", code: 2) // TODO: Перенести
            completion(.failure(error))
            return
        }
        storageManager.fetchChat(id: roomID, from: context)
            .subscribe { [completion] chat in
                completion(.success(nil))
            } onFailure: { [weak self, message] _ in
                _ = self?.storageManager.createChat(id: roomID,
                                                    targetUserUUID: message.sender?.id ?? "",
                                                    in: context)

                do {
                    try context.save()
                    self?.completion(.success(nil))
                } catch {
                    Logger.log(to: .error, message: "Не удалось сохранить контекст core data", error: error)
                    self?.completion(.failure(error))
                }
            }
            .disposed(by: bag)
    }
}
