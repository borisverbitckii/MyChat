//
//  AppFontsConfig.swift
//  MyChat
//
//  Created by Boris Verbitsky on 04.04.2022.
//

import UIKit

// Структура, чтобы иметь возможность удаленно настраивать шрифты и их размеры
public struct AppFontsConfig {
    public let baseFontName: String // базовый шрифт, если в других параметрах что-то пойдет не так

    public let registerViewController: [String: (fontName: String, fontSize: CGFloat)]
    public let chatsListViewController: [String: (fontName: String, fontSize: CGFloat)]
    public let profileViewController: [String: (fontName: String, fontSize: CGFloat)]
    // ключи - название ui элемента, значения - шрифт и размер

    public init(baseFontName: String,
                registerViewController: [String: (fontName: String, fontSize: CGFloat)],
                chatsListViewController: [String: (fontName: String, fontSize: CGFloat)],
                profileViewController: [String: (fontName: String, fontSize: CGFloat)]) {
        self.baseFontName = baseFontName
        self.registerViewController = registerViewController
        self.chatsListViewController = chatsListViewController
        self.profileViewController = profileViewController
    }
}
