//
//  Sender+CoreDataClass.swift
//  
//
//  Created by Boris Verbitsky on 05.05.2022.
//
//

import Logger
import CoreData
import Foundation

@objc(Sender)
public class Sender: NSManagedObject, Codable {

    // MARK: Private properties
    private enum CodingKeys: CodingKey {
        case id
    }

    // MARK: Init
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context!] as? NSManagedObjectContext else {
            fatalError()
        }
        guard let entity = NSEntityDescription.entity(forEntityName: "Sender", in: context) else {
            fatalError()
        }

        self.init(entity: entity, insertInto: context)
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decodeIfPresent(String.self, forKey: .id)
        } catch {
            Logger.log(to: .error, message: "Не получилось декодировать Sender", error: error)
        }
    }

    // MARK: Public Methods
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
    }
}
