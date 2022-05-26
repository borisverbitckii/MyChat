//
//  Profile.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Foundation

public struct ChatUser: Codable, Equatable { // TODO: Перекинуть в кор дату
    public let userID: String
    public let name: String?
    public let email: String?
    public let isEmailVerified: Bool?
    public let avatarURL: URL?

    public init(uid: String,
                name: String? = nil,
                email: String? = nil,
                isEmailVerified: Bool? = nil,
                avatarURL: URL? = nil) {
        self.userID = uid
        self.email = email
        self.isEmailVerified = isEmailVerified
        self.name = name
        self.avatarURL = avatarURL
    }
}
