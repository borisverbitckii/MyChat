//
//  Profile.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Foundation

public struct ChatUser: Codable {
    public let userID: String
    public let name: String?
    public let surname: String?
    public let email: String?
    public let isEmailVerified: Bool?
    public let avatarURL: URL?

    public init(uid: String,
                name: String? = nil,
                surname: String? = nil,
                email: String? = nil,
                isEmailVerified: Bool? = nil,
                avatarURL: URL? = nil) {
        self.userID = uid
        self.email = email
        self.isEmailVerified = isEmailVerified
        self.name = name
        self.surname = surname
        self.avatarURL = avatarURL
    }
}
