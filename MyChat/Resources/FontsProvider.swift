//
//  Fonts.swift
//  MyChat
//
//  Created by Boris Verbitsky on 04.04.2022.
//

import UIKit
import Models
import Logger

protocol FontsProviderProtocol {
    /// Клоужер для локальной настройки шрифта
    func getFont<E: RawRepresentable>() -> (E) -> (UIFont) where E.RawValue == String
}

/// Класс для возможности удаленной настройки всех шрифтов в приложении.
///
/// Обрабатывает удаленный конфиг AppFontsConfig, если он не nil, присваивает
/// стандартные значения. Все дефолтные шрифты для приложения устанавливаются в FontsDataSource.plist
final class FontsProvider<T>: Provider<Fonts> {
}

// MARK: - FontsProvider + FontsProviderProtocol  -
extension FontsProvider: FontsProviderProtocol {

    // MARK: Public Methods
    /// Функция для генерации клоужера, который будет поставлять шрифты
    /// - Returns: Возвращает клоужер, в котором можно будет выбрать нужный для контроллера ui элемент из перечисления
    func getFont<E: RawRepresentable>() -> (E) -> (UIFont) where E.RawValue == String {
        { [remoteConfig] uiElement in

            let viewControllerName = String(describing: T.self)

            guard let fontsForViewController = remoteConfig?()?.viewControllers[viewControllerName] else {
                Logger.log(to: .warning,
                           message: "В remoteConfig для шрифтов не найден контроллер \(viewControllerName)")
                return self.getDefaultFont(for: uiElement.rawValue)
            }

            guard let uiElementDict = fontsForViewController.uiElements[uiElement.rawValue] else {
                Logger.log(to: .warning,
                           message: "В remoteConfig для шрифтов не найден ui элемент \(uiElement.rawValue)")
                return self.getDefaultFont(for: uiElement.rawValue)
            }

            guard let fontSizeNumber = NumberFormatter().number(from: uiElementDict.fontSize),
                  let font = UIFont(name: uiElementDict.fontName,
                                    size: CGFloat(truncating: fontSizeNumber)) else {
                Logger.log(to: .error,
                           message: "Не удалось собрать UIFont для ui элемента' \(uiElement.rawValue) из remoteConfig")
                return self.getDefaultFont(for: uiElement.rawValue)
            }
            return font
        }
    }

    // MARK: Private methods
    private func getDefaultFont(for uiElementName: String) -> UIFont {

        let vcName = String(describing: T.self)

        guard let viewControllerDict = localConfig[vcName] as? [String: Any] else {
            Logger.log(to: .error,
                       message: "В локальном репозитории шрифтов не найден словарь для \(vcName)")
            return UIFont.systemFont(ofSize: 14)
        }

        guard let fontDict = viewControllerDict[uiElementName] as? [String: Any] else {
            Logger.log(to: .error,
                       message: "В локальном репозитории шрифтов не найден шрифт для \(uiElementName)")
            return UIFont.systemFont(ofSize: 14)
        }

        guard let fontName = fontDict["fontName"] as? String,
              let fontSize = fontDict["size"] as? CGFloat else {
            Logger.log(to: .error,
                       message: "Не удалось достать данные для UIFont для ui элемента' \(uiElementName) из локального репозитория")
            // swiftlint:disable:previous line_length
            return UIFont.systemFont(ofSize: 14)
        }

        guard let font = UIFont(name: fontName, size: fontSize) else {
            Logger.log(to: .error,
                       message: "Не удалось собрать UIFont для ui элемента' \(uiElementName) из локального репозитория")
            return UIFont.systemFont(ofSize: 14)
        }

        return font
    }
}
