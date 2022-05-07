//
//  Message+CoreDataProperties.swift
//  
//
//  Created by Boris Verbitsky on 05.05.2022.
//
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var action: MessageAction
    @NSManaged public var id: String?
    @NSManaged public var text: String?
    @NSManaged public var date: Date?
    @NSManaged public var room: Room?
    @NSManaged public var sender: Sender?
    @NSManaged public var chat: Chat?

}
