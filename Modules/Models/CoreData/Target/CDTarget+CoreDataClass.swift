//
//  Target+CoreDataClass.swift
//  
//
//  Created by Boris Verbitsky on 27.05.2022.
//
//

import Logger
import CoreData
import Foundation

@objc(CDTarget)
public class CDTarget: NSManagedObject, Encodable {

    // MARK: Private properties
    private enum CodingKeys: CodingKey {
        case id
    }

    // MARK: Public Methods
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
    }

    public func setup(with target: Target) {
        self.id = target.id
    }
}
