//
//  Chat.swift
//  MyChat
//
//  Created by Boris Verbitsky on 05.04.2022.
//

public struct Chat {
    public let contact: Contact
    public let lastMessage: Message

    public init(contact: Contact,
                lastMessage: Message) {
        self.contact = contact
        self.lastMessage = lastMessage
    }
}
