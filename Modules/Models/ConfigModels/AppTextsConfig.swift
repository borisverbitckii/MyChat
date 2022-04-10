//
//  AppTextsConfig.swift
//  MyChat
//
//  Created by Boris Verbitsky on 05.04.2022.
//

// Структура, чтобы иметь возможность удаленно настраивать шрифты и их размеры
public struct AppTextsConfig {
    public let registerViewController: [String: String]
    public let chatsListViewController: [String: String]
    public let profileViewController: [String: String]
    // ключи - название ui элемента, значения - текст

    public init(registerViewController: [String: String],
                chatsListViewController: [String: String],
                profileViewController: [String: String]) {
        self.registerViewController = registerViewController
        self.chatsListViewController = chatsListViewController
        self.profileViewController = profileViewController
    }
}
