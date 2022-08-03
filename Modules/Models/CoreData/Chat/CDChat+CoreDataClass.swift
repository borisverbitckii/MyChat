//
//  Chat+CoreDataClass.swift
//  
//
//  Created by Boris Verbitsky on 05.05.2022.
//
//

import Foundation
import CoreData

@objc(CDChat)
public class CDChat: NSManagedObject, Encodable {

    public func setupChat(chatID: String,
                          receiverUser: CDChatUser,
                          messages: NSSet? = nil) {
        self.id = chatID
        self.receiver = receiverUser
        self.messages = messages
        self.lastMessageDate = Date()
    }
}
