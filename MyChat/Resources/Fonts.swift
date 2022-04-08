//
//  Fonts.swift
//  MyChat
//
//  Created by Boris Verbitsky on 04.04.2022.
//

import UIKit

protocol FontsProtocol {
    // Для каждого контроллера создается свой метод, который возвращает
    // клоужер для локальной настройки
    func registerViewController() -> (RegisterViewControllerFonts) -> (UIFont)
    func chatsListViewController() -> (ChatsListViewControllerFonts) -> (UIFont)
    func profileViewController() -> (ProfileViewControllerFonts) -> (UIFont)
}

/*
 Класс для возможности удаленной настройки всех шрифтов в приложении
 Обрабатывает удаленный конфиг AppFontsConfig, если он не nil, присваивает
 стандартные значения. Все шрифты для приложения устанавливаются здесь
 */

final class Fonts {

    // MARK: Private Properties
    private var config: AppFontsConfig? // удаленный конфиг для настройки шрифтов

    // MARK: Init
    init(config: AppFontsConfig?) {
        self.config = config
    }

    // MARK: Private Methods
    private func getBaseFont() -> UIFont {
        if let config = config {
            if let font = UIFont(name: config.baseFontName, size: 20) {
                return font
            }
        }

        if let baseFont = UIFont(name: "Futura Medium", size: 20) {
            return baseFont
        }
        return UIFont()
    }
}

extension Fonts: FontsProtocol {

    // MARK: Public Methods
    func registerViewController() -> (RegisterViewControllerFonts) -> (UIFont) {
        return { [weak self] uiElement in
            guard let self = self else { return UIFont()}
            if let fontName = self.config?.registerViewController[uiElement.rawValue]?.fontName,
               // uiElement.rawValue - название ui элемента
               let fontSize = self.config?.registerViewController[uiElement.rawValue]?.fontSize,
               let font = UIFont(name: fontName,
                                 size: fontSize) {
                return font
            }

            if uiElement == .registerOrLabel {
                return UIFont(name: "Futura Medium", size: 24)!
            }

            if uiElement == .changeStateButton {
                return UIFont(name: "Futura Medium", size: 14)!
            }

            if uiElement == .registerErrorLabel {
                return UIFont(name: "Futura Medium", size: 14)!
            }

            if uiElement == .registerTextfield {
                return UIFont(name: "Futura Medium", size: 16)!
            }

            if uiElement == .submitButton {
                return UIFont(name: "Futura Medium", size: 20)!
            }
            return self.getBaseFont()
        }
    }

    func chatsListViewController() -> (ChatsListViewControllerFonts) -> (UIFont) {
        return { [weak self] uiElement in
            guard let self = self else { return UIFont()}
            if let fontName = self.config?.chatsListViewController[uiElement.rawValue]?.fontName,
               // uiElement.rawValue - название ui элемента
               let fontSize = self.config?.chatsListViewController[uiElement.rawValue]?.fontSize,
               let font = UIFont(name: fontName,
                                 size: fontSize) {
                return font
            }
            return self.getBaseFont()
        }
    }

    func profileViewController() -> (ProfileViewControllerFonts) -> (UIFont) {
        return { [weak self] uiElement in
            guard let self = self else { return UIFont()}
            if let fontName = self.config?.profileViewController[uiElement.rawValue]?.fontName,
               // uiElement.rawValue - название ui элемента
               let fontSize = self.config?.profileViewController[uiElement.rawValue]?.fontSize,
               let font = UIFont(name: fontName,
                                 size: fontSize) {
                return font
            }
            return self.getBaseFont()
        }
    }
}
