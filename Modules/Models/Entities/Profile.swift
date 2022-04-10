//
//  Profile.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Foundation

public struct Profile: Codable {
    public let profileID: String
    public let name: String
    public let surname: String
    public let avatar: Data

    public init(profileID: String,
                name: String,
                surname: String,
                avatar: Data) {
        self.profileID = profileID
        self.name = name
        self.surname = surname
        self.avatar = avatar
    }
}
