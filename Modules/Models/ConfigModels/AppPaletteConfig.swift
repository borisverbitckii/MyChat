//
//  AppPaletteConfig.swift
//  MyChat
//
//  Created by Boris Verbitsky on 07.04.2022.
//

import UIKit

// Структура, чтобы иметь возможность удаленно настраивать шрифты и их размеры
public struct AppPaletteConfig {
    public let colors: [String : [String: UIColor]]
    // - Общий ключ - имя контроллера
    // - Ключ значения - название ui элемента
    // - Значение значения - цвет

    public init(colors: [String : [String: UIColor]]) {
        self.colors = colors
    }
}
