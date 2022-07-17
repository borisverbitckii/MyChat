//
//  CDMessage+CoreDataProperties.swift
//  
//
//  Created by Boris Verbitsky on 31.05.2022.
//
//

import Foundation
import CoreData


extension CDMessage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDMessage> {
        return NSFetchRequest<CDMessage>(entityName: "CDMessage")
    }

    @NSManaged public var action: MessageAction
    @NSManaged public var position: MessagePosition
    @NSManaged public var date: String
    @NSManaged public var id: String?
    @NSManaged public var text: String?
    @NSManaged public var chat: CDChat?
    @NSManaged public var sender: CDChatUser?
    @NSManaged public var target: CDTarget?
}
