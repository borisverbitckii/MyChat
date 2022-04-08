//
//  AppFontsConfig.swift
//  MyChat
//
//  Created by Boris Verbitsky on 04.04.2022.
//

import UIKit

// Структура, чтобы иметь возможность удаленно настраивать шрифты и их размеры
struct AppFontsConfig {
    let baseFontName: String // базовый шрифт, если в других параметрах что-то пойдет не так

    let registerViewController: [String: (fontName: String, fontSize: CGFloat)]
    let chatsListViewController: [String: (fontName: String, fontSize: CGFloat)]
    let profileViewController: [String: (fontName: String, fontSize: CGFloat)]
    // ключи - название ui элемента, значения - шрифт и размер
}
