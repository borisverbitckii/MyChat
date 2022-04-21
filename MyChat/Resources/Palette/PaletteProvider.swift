//
//  Palette.swift
//  MyChat
//
//  Created by Boris Verbitsky on 06.04.2022.
//

import UIKit
import Models
import Logger

protocol PaletteProtocol {
    /// Клоужер для локальной настройки цвета
    func getColor<E: RawRepresentable>() -> (E) -> (UIColor) where E.RawValue == String
}

/// Класс для возможности удаленной настройки всех цветов в приложении
///
/// Обрабатывает удаленный конфиг AppPaletteConfig, если он не nil, присваивает
/// стандартные значения из Assets. Все дефолтные цвета для приложения устанавливаются здесь,
/// задаются в Assets для светлой и темной темы
final class PaletteProvider<T>: Provider<Palette> {}

// MARK: - Palette + PaletteProtocol  -
extension PaletteProvider: PaletteProtocol {

    // MARK: Public methods
    /// Функция для генерации клоужера, который будет поставлять цвета
    /// - Returns: Возвращает клоужер, в котором можно будет выбрать нужный для контроллера ui элемент из перечисления
    func getColor<E: RawRepresentable>() -> (E) -> (UIColor) where E.RawValue == String {
        { [remoteConfig]  uiElement in
            let viewControllerName = String(describing: T.self)
            guard let colorsForViewController = remoteConfig?()?.viewControllers[viewControllerName] else {
                Logger.log(to: .warning,
                           message: "В remoteConfig для цветов не найден контроллер \(viewControllerName)")
                guard let localColor = UIColor(named: uiElement.rawValue) else {
                    Logger.log(to: .error,
                               message: "Не найден цвет из assets для \(uiElement.rawValue)")
                    return UIColor()
                }
                return localColor
            }

            guard let colorsPair = colorsForViewController.uiElements[uiElement.rawValue] else {
                Logger.log(to: .warning,
                           message: "В remoteConfig для цветов не найден ui элемент \(uiElement.rawValue)")
                guard let localColor = UIColor(named: uiElement.rawValue) else {
                    Logger.log(to: .error,
                               message: "Не найден цвет из assets для \(uiElement.rawValue)")
                    return UIColor()
                }
                return localColor
            }

            var color: UIColor?

            switch UIScreen.main.traitCollection.userInterfaceStyle {
            case .unspecified, .light:
                color = UIColor.colorWithHexString(hexString: colorsPair.lightModeHex)
            case .dark:
                color = UIColor.colorWithHexString(hexString: colorsPair.darkModeHex)
            @unknown default:
                break
            }

            guard let color = color else {
                Logger.log(to: .warning,
                           message: "Не получилось конвертировать hex для \(uiElement.rawValue)")
                guard let localColor = UIColor(named: uiElement.rawValue) else {
                    Logger.log(to: .error,
                               message: "Не найден цвет из assets для \(uiElement.rawValue)")
                    return UIColor()
                }
                return localColor
            }

            return color
        }
    }
}
