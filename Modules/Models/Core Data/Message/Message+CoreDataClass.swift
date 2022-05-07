//
//  Message+CoreDataClass.swift
//  
//
//  Created by Boris Verbitsky on 05.05.2022.
//
//

import Logger
import CoreData
import Foundation

@objc(Message)
public class Message: NSManagedObject, Codable {

    // MARK: Private properties
    private enum CodingKeys: String, CodingKey {
        case action, date, room, sender
        case text = "message"
        case id = "messageID"
    }

    // MARK: Init
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context!] as? NSManagedObjectContext else {
            fatalError()
        }
        guard let entity = NSEntityDescription.entity(forEntityName: "Message", in: context) else {
            fatalError()
        }

        self.init(entity: entity, insertInto: context)

        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decodeIfPresent(String.self, forKey: .id)
            self.action = try container.decode(MessageAction.self, forKey: .action)
            self.date = try container.decodeIfPresent(Date.self, forKey: .date)
            self.room = try container.decodeIfPresent(Room.self, forKey: .room)
            self.sender = try container.decodeIfPresent(Sender.self, forKey: .sender)
        } catch {
            Logger.log(to: .error, message: "Не получилось декодировать Message", error: error)
        }
    }

    // MARK: Public Methods
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(action, forKey: .action)
        try container.encodeIfPresent(date, forKey: .date)
        try container.encodeIfPresent(room, forKey: .room)
        try container.encodeIfPresent(sender, forKey: .sender)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encodeIfPresent(id, forKey: .id)
    }

    public func setup(action: MessageAction,
                      id: String = UUID().uuidString,
                      text: String,
                      date: Date = Date(),
                      room: Room? = nil,
                      sender: Sender? = nil) {
        self.action = action
        self.id = id
        self.text = text
        self.date = date
        self.room = room
        self.sender = sender
    }
}
