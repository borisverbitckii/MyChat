//
//  Fonts.swift
//  MyChat
//
//  Created by Boris Verbitsky on 04.04.2022.
//

import UIKit

enum ButtonFontType: String {
    // RegisterViewController
    case submitButton, changeStateButton
}

enum TextfieldFontType: String {
    // RegisterViewController
    case registerTextfield
}

enum LabelFontType: String {
    // RegisterViewController
    case registerErrorLabel
}

protocol FontsProtocol {
    func buttons() -> (ButtonFontType) -> (UIFont)
    func textfields() -> (TextfieldFontType) -> (UIFont)
    func labels() -> (LabelFontType) -> (UIFont)
}

final class Fonts {
    // MARK: - Private Properties -
    private var config: AppFontsConfig? // удаленный конфиг для настройки шрифтов

    // MARK: - Init -
    init(config: AppFontsConfig?) {
        self.config = config
    }

    // MARK: - Private Methods -
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

    // MARK: - Public Methods -
    func buttons() -> (ButtonFontType) -> (UIFont) {
        return { [weak self] buttonType in
            guard let self = self else { return UIFont()}
            if let buttonFontName = self.config?.buttonsFonts[buttonType.rawValue]?.fontName,
               // buttonType.rawValue - название кнопки
               let buttonFontSize = self.config?.buttonsFonts[buttonType.rawValue]?.fontSize,
               let font = UIFont(name: buttonFontName,
                                 size: buttonFontSize) {
                return font
            } // TODO: Доделать стандартные кейсы с размерами
            return self.getBaseFont()
        }
    }

    func textfields() -> (TextfieldFontType) -> (UIFont) {
        return { [weak self] textfieldFontType in
            guard let self = self else { return UIFont() }
            if let textfieldFontName = self.config?.textfieldsFonts[textfieldFontType.rawValue]?.fontName,
               let textfieldFontSize = self.config?.textfieldsFonts[textfieldFontType.rawValue]?.fontSize,
               let font = UIFont(name: textfieldFontName,
                                 size: textfieldFontSize) {
                return font
            } // TODO: Доделать стандартные кейсы с размерами
            return self.getBaseFont()
        }
    }

    func labels() -> (LabelFontType) -> (UIFont) {
        return { [weak self] labelFontType in
            guard let self = self else { return UIFont() }
            if let labelFontName = self.config?.labelFonts[labelFontType.rawValue]?.fontName,
               let labelFontSize = self.config?.labelFonts[labelFontType.rawValue]?.fontSize,
               let font = UIFont(name: labelFontName,
                                 size: labelFontSize) {
                return font
            } // TODO: Доделать стандартные кейсы с размерами
            return self.getBaseFont()
        }
    }
}
