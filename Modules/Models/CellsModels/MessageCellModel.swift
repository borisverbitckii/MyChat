//
//  MessageCellModel.swift
//  Models
//
//  Created by Boris Verbitsky on 05.07.2022.
//

import UIKit

public struct MessageCellModel {
    public let baseFont: UIFont
    public let timeFont: UIFont
    public let messageBubleBackgroundColor: UIColor

    public init(baseFont: UIFont,
                timeFont: UIFont,
                messageBubleBackgroundColor: UIColor) {
        self.baseFont = baseFont
        self.timeFont = timeFont
        self.messageBubleBackgroundColor = messageBubleBackgroundColor
    }
}
