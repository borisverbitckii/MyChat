//
//  ChatCellModel.swift
//  Models
//
//  Created by Boris Verbitsky on 26.05.2022.
//

import UIKit

public struct ChatCellModel {
    public let messageText: String
    public let messageDate: String
    public let baseFont: UIFont

    // MARK: Init
    public init(messageText: String,
                messageDate: String,
                baseFont: UIFont) {
        self.messageText = messageText
        self.messageDate = messageDate
        self.baseFont = baseFont
    }
}
