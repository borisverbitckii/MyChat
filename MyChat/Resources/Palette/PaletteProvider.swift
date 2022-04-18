//
//  Palette.swift
//  MyChat
//
//  Created by Boris Verbitsky on 06.04.2022.
//

import UIKit
import Models

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
                // TODO: Залогировать отсутствие значения из конфига
                guard let localColor = UIColor(named: uiElement.rawValue) else {
                    assert(UIColor(named: uiElement.rawValue) != nil,
                           AssertionErrorMessages.noColor.assertionErrorMessage)
                    return UIColor()
                }
                return localColor
            }

            guard let colorsPair = colorsForViewController.uiElements[uiElement.rawValue] else {
                // TODO: Залогировать отсутствие значения из конфига
                guard let localColor = UIColor(named: uiElement.rawValue) else {
                    assert(UIColor(named: uiElement.rawValue) != nil,
                           AssertionErrorMessages.noColor.assertionErrorMessage)
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
                // TODO: Залогировать невозможность перевести hex
                guard let localColor = UIColor(named: uiElement.rawValue) else {
                    assert(UIColor(named: uiElement.rawValue) != nil,
                           AssertionErrorMessages.noColorByHex.assertionErrorMessage)
                    return UIColor()
                }
                return localColor
            }

            return color
        }
    }
}
