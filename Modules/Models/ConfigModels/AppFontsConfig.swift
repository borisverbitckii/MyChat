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
    public let fonts: [String: [String: (fontName: String, fontSize: CGFloat)]]
    // - Общий ключ - имя контроллера
    // - Ключ значения - название ui элемента
    // - (fontName: String, fontSize: CGFloat) - название и размер шрифта

    public init(baseFontName: String,
                fonts: [String: [String: (fontName: String, fontSize: CGFloat)]]) {
        self.baseFontName = baseFontName
        self.fonts = fonts
    }
}
