//
//  Message+CoreDataProperties.swift
//  
//
//  Created by Boris Verbitsky on 24.05.2022.
//
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var action: MessageAction
    @NSManaged public var date: String?
    @NSManaged public var id: String?
    @NSManaged public var text: String?
    @NSManaged public var chat: Chat?
    @NSManaged public var room: Room?
    @NSManaged public var sender: Sender?

}
