//
//  CDChat+CoreDataProperties.swift
//  
//
//  Created by Boris Verbitsky on 31.05.2022.
//
//

import Foundation
import CoreData


extension CDChat {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDChat> {
        return NSFetchRequest<CDChat>(entityName: "CDChat")
    }

    @NSManaged public var lastMessageDate: Date?
    @NSManaged public var id: String?
    @NSManaged public var messages: NSSet?
    @NSManaged public var receiver: CDChatUser?

}

// MARK: Generated accessors for messages
extension CDChat {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: CDMessage)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: CDMessage)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}
