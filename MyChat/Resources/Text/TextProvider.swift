//
//  Text.swift
//  MyChat
//
//  Created by Борис on 13.02.2022.
//

import UIKit
import Models
import Logger

protocol TextProviderProtocol {
    /// Клоужер для локальной настройки текста
    func getText<E: RawRepresentable>() -> (E) -> (String) where E.RawValue == String
}

/// Класс для возможности удаленной настройки всех текстов в приложении
///
/// Обрабатывает удаленный конфиг AppTextsConfig, если он nil, присваивает
/// стандартные значения. Все дефолтные текста для приложения устанавливаются в TextsDataSource.plist
final class TextProvider <T>: Provider<Texts> {}

// MARK: - TextProvider + TextProtocol -
extension TextProvider: TextProviderProtocol {

    // MARK: Public methods
    /// Функция для генерации клоужера, который будет поставлять тексты
    /// - Returns: Возвращает клоужер, в котором можно будет выбрать нужный для контроллера ui элемент из перечисления
    func getText<E: RawRepresentable>() -> (E) -> (String) where E.RawValue == String {
        { [remoteConfig] uiElement in
            let viewControllerName = String(describing: T.self)

            guard let textsForViewController = remoteConfig?()?.viewControllers[viewControllerName] else {
                Logger.log(to: .warning,
                           message: "В remoteConfig для текста не найден контроллер \(viewControllerName)")
                return self.getDefaultText(for: uiElement.rawValue)
            }

            guard let uiElement = textsForViewController.uiElements[uiElement.rawValue] else {
                Logger.log(to: .warning,
                           message: "В remoteConfig для текста не найден ui элемент \(uiElement.rawValue)")
                return self.getDefaultText(for: uiElement.rawValue)
            }
            return uiElement.text
        }
    }

    // MARK: Private methods
    private func getDefaultText(for uiElementName: String) -> String {
        let viewControllerName = String(describing: T.self)

        guard let viewControllerDict = self.localConfig[viewControllerName] as? [String: Any] else {
            Logger.log(to: .error,
                       message: "В локальном репозитории текстов не найден словарь для \(viewControllerName)")
            return "" }

        guard let string = viewControllerDict[uiElementName] as? String else {
            Logger.log(to: .error,
                       message: "В локальном репозитории текстов не найден текст для \(uiElementName)")
            return "" }
        return string
    }
}
