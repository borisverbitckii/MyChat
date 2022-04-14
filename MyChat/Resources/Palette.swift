//
//  Palette.swift
//  MyChat
//
//  Created by Boris Verbitsky on 06.04.2022.
//

import UIKit
import Models

protocol PaletteProtocol {
    // Для каждого контроллера создается свой метод, который возвращает
    // клоужер для локальной настройки
    func registerViewController() -> (RegisterViewControllerPalette) -> (UIColor)
    func chatsListViewController() -> (ChatsListViewControllerPalette) -> (UIColor)
    func profileViewController() -> (ProfileViewControllerPalette) -> (UIColor)
}

/* Класс для возможности удаленной настройки всех цветов в приложении
 Обрабатывает удаленный конфиг AppPaletteConfig, если он не nil, присваивает
 стандартные значения из Assets. Все цвета для приложения устанавливаются здесь,
 задаются в Assets для светлой и темной темы */

final class Palette {

    // MARK: Private Properties
    private let config: AppPaletteConfig?

    // MARK: Init
    init(config: AppPaletteConfig?) {
        self.config = config
    }

}

// MARK: - Palette + PaletteProtocol  -
extension Palette: PaletteProtocol {

    // MARK: Public methods
    func splashViewController() -> (SplashViewControllerPalette) -> (UIColor) {
        return { [weak self] color in
            guard let self = self else { return UIColor()}
            if let color = self.config?.splashViewController[color.rawValue] {
                return color
            }

            assert(UIColor(named: color.rawValue) != nil, "Цвет не найден")
            return UIColor(named: color.rawValue)!
        }
    }

    // MARK: Public methods
    func splachViewController() -> (EmptyViewControllerPalette) -> (UIColor) {
        return { [weak self] color in
            guard let self = self else { return UIColor()}
            if let color = self.config?.emptyViewController[color.rawValue] {
                return color
            }
            assert(UIColor(named: color.rawValue) != nil, "Цвет не найден")
            return UIColor(named: color.rawValue)!
        }
    }

    func registerViewController() -> (RegisterViewControllerPalette) -> (UIColor) {
        return { [weak self] color in

            guard let self = self else { return UIColor()}
            if let color = self.config?.registerViewController[color.rawValue] {
                return color
            }

            assert(UIColor(named: color.rawValue) != nil, "Цвет не найден")
            return UIColor(named: color.rawValue)!
        }
    }

    func chatsListViewController() -> (ChatsListViewControllerPalette) -> (UIColor) {
        return { [weak self] color in

            guard let self = self else { return UIColor()}
            if let color = self.config?.chatsListViewController[color.rawValue] {
                return color
            }

            assert(UIColor(named: color.rawValue) != nil, "Цвет не найден")
            return UIColor(named: color.rawValue)!
        }
    }

    func profileViewController() -> (ProfileViewControllerPalette) -> (UIColor) {
        return { [weak self] color in

            guard let self = self else { return UIColor()}
            if let color = self.config?.profileViewController[color.rawValue] {
                return color
            }

            assert(UIColor(named: color.rawValue) != nil, "Цвет не найден")
            return UIColor(named: color.rawValue)!
        }
    }
}
