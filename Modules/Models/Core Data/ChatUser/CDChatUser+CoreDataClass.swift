//
//  ChatUser+CoreDataClass.swift
//  
//
//  Created by Boris Verbitsky on 29.05.2022.
//
//

import Logger
import CoreData
import Foundation

@objc(CDChatUser)
public class CDChatUser: NSManagedObject, Encodable {

    // MARK: Private properties
    private enum CodingKeys: CodingKey {
        case id, name, email, avatarURL
    }

    // MARK: Public Methods
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encodeIfPresent(avatarURL, forKey: .avatarURL)
    }

    public func setup(id: String,
                      name: String,
                      email: String,
                      avatarURL: String?) {
        self.id        = id
        self.name      = name
        self.email     = email
        self.avatarURL = avatarURL
    }

    public func setup(with user: ChatUser) {
        self.id        = user.id
        self.name      = user.name
        self.email     = user.email
        self.avatarURL = user.avatarURL
    }
}
