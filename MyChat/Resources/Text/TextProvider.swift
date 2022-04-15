//
//  Text.swift
//  MyChat
//
//  Created by Борис on 13.02.2022.
//

import UIKit
import Models

protocol TextProviderProtocol {
    // Клоужер для локальной настройки текста
    func getText<E: RawRepresentable>() -> (E) -> (String) where E.RawValue == String
}

/*
 Класс для возможности удаленной настройки всех текстов в приложении
 Обрабатывает удаленный конфиг AppTextsConfig, если он nil, присваивает
 стандартные значения. Все текста для приложения устанавливаются в TextsDataSource.plist
 */

final class TextProvider <T: UIViewController>: Provider<AppTextsConfig> {}

// MARK: - TextProvider + TextProtocol -
extension TextProvider: TextProviderProtocol {

    // MARK: Public methods
    /// Функция для генерации клоужера, который будет поставлять тексты
    /// - Returns: Возвращает клоужер, в котором можно будет выбрать нужный для контроллера ui элемент из перечисления
    func getText<E: RawRepresentable>() -> (E) -> (String) where E.RawValue == String {
        { [remoteConfig] uiElement in
            let viewControllerName = String(describing: T.self)

            guard let uiElementsDict = remoteConfig?.texts[viewControllerName] else {
                // TODO: Залогировать отсутствие значения из конфига
                return self.getDefaultText(for: uiElement.rawValue)
            }

            guard let string = uiElementsDict[uiElement.rawValue] else {
                // TODO: Залогировать отсутствие значения из конфига
                return self.getDefaultText(for: uiElement.rawValue)
            }

            return string
        }
    }

    // MARK: Private methods
    private func getDefaultText(for uiElementName: String) -> String {
        let viewControllerName = String(describing: T.self)

        guard let viewControllerDict = self.localConfig[viewControllerName] as? [String: Any] else {
            assertionFailure(AssertionErrorMessages.noElementInPlist(viewControllerName).assertionErrorMessage)
            return "" }

        guard let string = viewControllerDict[uiElementName] as? String else {
            assertionFailure(AssertionErrorMessages.noText(uiElementName).assertionErrorMessage)
            return "" }
        return string
    }
}
