//
//  AppPaletteConfig.swift
//  MyChat
//
//  Created by Boris Verbitsky on 07.04.2022.
//

import UIKit

// Структура, чтобы иметь возможность удаленно настраивать шрифты и их размеры
public struct AppPaletteConfig {
    public let registerViewController: [String: UIColor]
    public let chatsListViewController: [String: UIColor]
    public let profileViewController: [String: UIColor]
    // ключи - название ui элемента, значения - цвет

    public init(registerViewController: [String: UIColor],
                chatsListViewController: [String: UIColor],
                profileViewController: [String: UIColor]) {
        self.registerViewController = registerViewController
        self.chatsListViewController = chatsListViewController
        self.profileViewController = profileViewController
    }
}
