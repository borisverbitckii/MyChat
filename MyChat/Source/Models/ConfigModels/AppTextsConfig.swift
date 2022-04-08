//
//  AppTextsConfig.swift
//  MyChat
//
//  Created by Boris Verbitsky on 05.04.2022.
//

// Структура, чтобы иметь возможность удаленно настраивать шрифты и их размеры
struct AppTextsConfig {
    let registerViewController: [String: String]
    let chatsListViewController: [String: String]
    let profileViewController: [String: String]
    // ключи - название ui элемента, значения - текст
}
