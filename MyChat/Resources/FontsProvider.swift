//
//  Fonts.swift
//  MyChat
//
//  Created by Boris Verbitsky on 04.04.2022.
//

import UIKit
import Models

protocol FontsProviderProtocol {
    func getFont<E: RawRepresentable>() -> (E) -> (UIFont) where E.RawValue == String
}

/*
 Класс для возможности удаленной настройки всех шрифтов в приложении
 Обрабатывает удаленный конфиг AppFontsConfig, если он не nil, присваивает
 стандартные значения. Все шрифты для приложения устанавливаются в FontsDataSource.plist
 */

final class FontsProvider<T: UIViewController>: Provider<AppFontsConfig> {

    // MARK: Private Methods
    private func getBaseFont() -> UIFont {
        if let config = remoteConfig {
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

// MARK: - FontsProvider + FontsProviderProtocol  -
extension FontsProvider: FontsProviderProtocol {

    // MARK: Public Methods
    /// Функция для генерации клоужера, который будет поставлять шрифты
    /// - Returns: Возвращает клоужер, в котором можно будет выбрать нужный для контроллера ui элемент из перечисления
    func getFont<E: RawRepresentable>() -> (E) -> (UIFont) where E.RawValue == String {
        { [remoteConfig] uiElement in
            let viewControllerName = String(describing: T.self)

            guard let viewControllerDict = remoteConfig?.fonts[viewControllerName] else {
                // TODO: Залогировать отсутствие значения из конфига
                return self.getDefaultFont(for: uiElement.rawValue)
            }

            guard let uiElementDict = viewControllerDict[uiElement.rawValue] else {
                // TODO: Залогировать отсутствие значения из конфига
                return self.getDefaultFont(for: uiElement.rawValue)
            }

            guard let font = UIFont(name: uiElementDict.fontName,
                                    size: uiElementDict.fontSize) else {
                assertionFailure(AssertionErrorMessages
                    .noFont(uiElement.rawValue)
                    .assertionErrorMessage)
                return self.getDefaultFont(for: uiElement.rawValue)
            }
            return font
        }
    }

    // MARK: Private methods
    private func getDefaultFont(for uiElementName: String) -> UIFont {

        let vcName = String(describing: T.self)

        guard let viewControllerDict = self.localConfig[vcName] as? [String: Any] else {
            assertionFailure(AssertionErrorMessages
                .noDataForController(vcName)
                .assertionErrorMessage)
            return getBaseFont() }

        guard let fontDict = viewControllerDict[uiElementName] as? [String: Any] else {
            assertionFailure(AssertionErrorMessages
                .noElementInPlist(uiElementName)
                .assertionErrorMessage)
            return getBaseFont() }

        guard let fontName = fontDict["fontName"] as? String,
              let fontSize = fontDict["size"] as? CGFloat else {
            assertionFailure(AssertionErrorMessages
                .noFontNameOrFontSize(uiElementName)
                .assertionErrorMessage)
            return getBaseFont()
        }

        guard let font = UIFont(name: fontName, size: fontSize) else {
            assertionFailure(AssertionErrorMessages.noFont(uiElementName).assertionErrorMessage)
            return getBaseFont()
        }

        return font
    }
}
