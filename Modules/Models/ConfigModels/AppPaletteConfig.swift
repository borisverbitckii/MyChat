//
//  AppPaletteConfig.swift
//  MyChat
//
//  Created by Boris Verbitsky on 07.04.2022.
//

import UIKit

// Структура, чтобы иметь возможность удаленно настраивать шрифты и их размеры
public struct AppPaletteConfig {
    public let emptyViewController: [String: UIColor]
    public let splashViewController: [String: UIColor]
    public let registerViewController: [String: UIColor]
    public let chatsListViewController: [String: UIColor]
    public let profileViewController: [String: UIColor]
    // ключи - название ui элемента, значения - цвет

    public init(emptyViewController: [String: UIColor],
                splashViewController: [String: UIColor],
                registerViewController: [String: UIColor],
                chatsListViewController: [String: UIColor],
                profileViewController: [String: UIColor]) {
        self.emptyViewController = emptyViewController
        self.splashViewController = splashViewController
        self.registerViewController = registerViewController
        self.chatsListViewController = chatsListViewController
        self.profileViewController = profileViewController
    }
}
