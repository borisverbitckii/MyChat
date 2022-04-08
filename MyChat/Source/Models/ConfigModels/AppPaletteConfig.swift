//
//  AppPaletteConfig.swift
//  MyChat
//
//  Created by Boris Verbitsky on 07.04.2022.
//

// Структура, чтобы иметь возможность удаленно настраивать шрифты и их размеры
struct AppPaletteConfig {
    let registerViewController: [String: UIColor]
    let chatsListViewController: [String: UIColor]
    let profileViewController: [String: UIColor]
    // ключи - название ui элемента, значения - цвет
}
