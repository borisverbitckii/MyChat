//
//  Chat+CoreDataClass.swift
//  
//
//  Created by Boris Verbitsky on 05.05.2022.
//
//

import Foundation
import CoreData

@objc(Chat)
public class Chat: NSManagedObject, Encodable { // TODO: Проверить encodable

    public func setupChat(chatID: String,
                          targetUserUUID: String? = nil,
                          messages: NSSet? = nil) {
        self.id = chatID
        self.targetUserUUID = targetUserUUID
        self.messages = messages
        self.creationDate = Date()
    }
}
