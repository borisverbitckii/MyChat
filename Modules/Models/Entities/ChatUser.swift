//
//  ChatUser.swift
//  Models
//
//  Created by Boris Verbitsky on 30.05.2022.
//

import Foundation

public struct ChatUser: Equatable, Codable {

    public let id: String
    public var name: String
    public let email: String
    public var avatarURL: String?

    // MARK: Init
    public init(id: String,
                name: String,
                email: String,
                avatarURL: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.avatarURL = avatarURL
    }

    public init(coreDataUser: CDChatUser) {
        self.id        = coreDataUser.id
        self.name      = coreDataUser.name
        self.email     = coreDataUser.email 
        self.avatarURL = coreDataUser.avatarURL
    }
}
