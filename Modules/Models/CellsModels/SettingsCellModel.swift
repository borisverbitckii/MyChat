//
//  SettingsCellModel.swift
//  Models
//
//  Created by Boris Verbitsky on 30.06.2022.
//

import UIKit

public struct SettingsCellModel {
    public let title: String
    public let font: UIFont
    public let backgroundColor: UIColor
    public let fontColor: UIColor
    public let action: () -> Void

    public init(title: String,
                font: UIFont,
                backgroundColor: UIColor,
                fontColor: UIColor,
                action: @escaping () -> Void) {
        self.title = title
        self.font = font
        self.backgroundColor = backgroundColor
        self.fontColor = fontColor
        self.action = action
    }
}
