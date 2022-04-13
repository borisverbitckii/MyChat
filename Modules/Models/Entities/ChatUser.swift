//
//  Profile.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Foundation

public struct ChatUser: Codable {
    public let uid: String
    public let email: String?
    public let isEmailVerified: Bool?
    public let name: String?
    public let surname: String?
    public let avatarURL: URL?

    public init(uid: String,
                email: String? = nil,
                isEmailVerified: Bool? = nil,
                name: String? = nil,
                surname: String? = nil,
                avatarURL: URL? = nil) {
        self.uid = uid
        self.email = email
        self.isEmailVerified = isEmailVerified
        self.name = name
        self.surname = surname
        self.avatarURL = avatarURL
    }
}
