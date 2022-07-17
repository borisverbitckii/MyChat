//
//  CDChatUser+CoreDataProperties.swift
//  
//
//  Created by Boris Verbitsky on 31.05.2022.
//
//

import Foundation
import CoreData


extension CDChatUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDChatUser> {
        return NSFetchRequest<CDChatUser>(entityName: "CDChatUser")
    }

    @NSManaged public var avatarURL: String?
    @NSManaged public var email: String
    @NSManaged public var id: String
    @NSManaged public var isEmailVerified: Bool
    @NSManaged public var name: String
    @NSManaged public var chat: CDChat?
    @NSManaged public var message: NSSet?
}

// MARK: Generated accessors for message
extension CDChatUser {

    @objc(addMessageObject:)
    @NSManaged public func addToMessage(_ value: CDMessage)

    @objc(removeMessageObject:)
    @NSManaged public func removeFromMessage(_ value: CDMessage)

    @objc(addMessage:)
    @NSManaged public func addToMessage(_ values: NSSet)

    @objc(removeMessage:)
    @NSManaged public func removeFromMessage(_ values: NSSet)

}
