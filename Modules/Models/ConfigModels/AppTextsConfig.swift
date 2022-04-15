//
//  AppTextsConfig.swift
//  MyChat
//
//  Created by Boris Verbitsky on 05.04.2022.
//

// Структура, чтобы иметь возможность удаленно настраивать шрифты и их размеры
public struct AppTextsConfig {
    public let texts: [String: [String: String]]
    // - Общий ключ - имя контроллера
    // - Ключ значения - название ui элемента
    // - Значение значения - текст

    public init(texts: [String: [String: String]]) {
        self.texts = texts
    }
}
