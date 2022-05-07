//
//  Sender+CoreDataProperties.swift
//  
//
//  Created by Boris Verbitsky on 05.05.2022.
//
//

import Foundation
import CoreData


extension Sender {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sender> {
        return NSFetchRequest<Sender>(entityName: "Sender")
    }

    @NSManaged public var id: String?
    @NSManaged public var message: Message?

}
