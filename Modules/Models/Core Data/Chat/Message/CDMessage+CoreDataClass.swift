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

@objc(CDMessage)
public class CDMessage: NSManagedObject, Encodable {

    // MARK: Private properties
    private enum CodingKeys: String, CodingKey {
        case action, date, target, sender,text, id
    }

    // MARK: Public Methods
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(action, forKey: .action)
        try container.encodeIfPresent(date, forKey: .date)
        try container.encodeIfPresent(target, forKey: .target)
        try container.encodeIfPresent(sender, forKey: .sender)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encodeIfPresent(id, forKey: .id)
    }

    public func setup(action: MessageAction,
                      position: MessagePosition,
                      id: String = UUID().uuidString,
                      text: String,
                      target: CDTarget? = nil,
                      sender: CDChatUser? = nil) {
        self.action   = action
        self.id       = id
        self.text     = text
        self.date     = Date().timeIntervalSince1970.description
        self.target   = target
        self.sender   = sender
        self.position = position
    }

    public func setup(with message: ReceivedMessage) {
        self.action   = message.action
        self.position = message.position
        self.id       = message.id
        self.text     = message.text
        self.date     = message.date
        guard let context = managedObjectContext else { return }
        
        if let originalTarget = message.target {
            let target = CDTarget(context: context)
            target.setup(with: originalTarget)
            self.target = target
        }
        if let originalSender = message.sender {
            let sender = CDChatUser(context: context)
            sender.setup(with: originalSender)
            self.sender = sender
        }
    }
}
