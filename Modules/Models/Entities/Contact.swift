//
//  Sender.swift
//  MyChat
//
//  Created by Boris Verbitsky on 05.04.2022.
//

public struct Contact {
    public let name: String
    public let surname: String
    public var nameAndSurname: String {
        return name + " " + surname
    }
    public let userIcon: String

    public init(name: String,
                surname: String,
                userIcon: String) {
        self.name = name
        self.surname = surname
        self.userIcon = userIcon
    }
}
