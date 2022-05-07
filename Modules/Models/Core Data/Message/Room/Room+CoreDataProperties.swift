//
//  Room+CoreDataProperties.swift
//  
//
//  Created by Boris Verbitsky on 05.05.2022.
//
//

import Foundation
import CoreData


extension Room {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Room> {
        return NSFetchRequest<Room>(entityName: "Room")
    }

    @NSManaged public var id: String?
    @NSManaged public var message: Message?

}
