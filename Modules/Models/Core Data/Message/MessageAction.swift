//
//  MessageAction.swift
//  Models
//
//  Created by Boris Verbitsky on 04.05.2022.
//

import Foundation

@objc public enum MessageAction: Int16, Codable {
    case sendMessageAction     = 0
    case joinRoomAction        = 1
    case leaveRoomAction       = 2
    case userJoinedAction      = 3
    case userLeftAction        = 4
    case joinRoomPrivateAction = 5
    case roomJoinedAction      = 6

    var action: String {
        switch self {
        case .sendMessageAction:
            return "send-message"
        case .joinRoomAction:
            return "join-room"
        case .leaveRoomAction:
            return "leave-room"
        case .userJoinedAction:
            return "user-join"
        case .userLeftAction:
            return "user-left"
        case .joinRoomPrivateAction:
            return "join-room-private"
        case .roomJoinedAction:
            return "room-joined"
        }
    }
}
