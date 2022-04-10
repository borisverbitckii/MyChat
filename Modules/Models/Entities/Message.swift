//
//  Message.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Foundation

public struct Message {
    public let sender: Contact
    public let text: String
    public let time: Date
    public var isRead: Bool

    public init( sender: Contact,
                 text: String,
                 time: Date,
                 isRead: Bool) {
        self.sender = sender
        self.text = text
        self.time = time
        self.isRead = isRead
    }
}
