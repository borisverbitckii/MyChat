//
//  Target+CoreDataProperties.swift
//  
//
//  Created by Boris Verbitsky on 27.05.2022.
//
//

import Foundation
import CoreData


extension CDTarget {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDTarget> {
        return NSFetchRequest<CDTarget>(entityName: "CDTarget")
    }

    @NSManaged public var id: String
    @NSManaged public var message: CDMessage?

}
