//
//  Message.swift
//  Models
//
//  Created by Boris Verbitsky on 31.05.2022.
//

import Foundation

public struct ReceivedMessage: Decodable {

    enum CodingKeys: CodingKey {
        case id
        case action
        case text
        case date
        case sender
        case target
    }

    // MARK: Public properties
    public let id:       String?
    public let action:   MessageAction
    public var position: MessagePosition = .left
    public let text:     String?
    public let date:     String
    public var sender:   ChatUser?
    public var target:   Target?

    // MARK: Init
    public init(id:       String? = nil,
                action:   MessageAction,
                text:     String? = nil,
                date:     String,
                sender:   ChatUser? = nil,
                target:   Target? = nil) {
        self.id       = id
        self.action   = action
        self.text     = text
        self.date     = date
        self.sender   = sender
        self.target   = target
    }
}
