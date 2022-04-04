//
//  AppFontsConfig.swift
//  MyChat
//
//  Created by Boris Verbitsky on 04.04.2022.
//

// Структура, чтобы иметь возможность удаленно настраивать шрифты и их размеры
struct AppFontsConfig {
    let baseFontName: String // базовый шрифт, если в других параметрах что-то пойдет не так

    let buttonsFonts: [String: (fontName: String, fontSize: CGFloat)]
    let textfieldsFonts: [String: (fontName: String, fontSize: CGFloat)]
    let labelFonts: [String: (fontName: String, fontSize: CGFloat)]
    // ключи - название текстфилда, значение - название шрифта + его размер
}
