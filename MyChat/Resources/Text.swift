//
//  Text.swift
//  MyChat
//
//  Created by Борис on 13.02.2022.
//

protocol TextProtocol {
    // Для каждого контроллера создается свой метод, который возвращает
    // клоужер для локальной настройки
    func registerViewController() -> (RegisterViewControllerTexts) -> (String)
    func chatsListViewController() -> (ChatsListViewControllerTexts) -> (String)
    func profileViewController() -> (ProfileViewControllerTexts) -> (String)
}

/*
 Класс для возможности удаленной настройки всех текстов в приложении
 Обрабатывает удаленный конфиг AppTextsConfig, если он не nil, присваивает
 стандартные значения. Все текста для приложения устанавливаются здесь
 */

final class Text {

    // MARK: Private Properties
    private var config: AppTextsConfig? // удаленный конфиг для настройки текста

    // MARK: Init
    init(config: AppTextsConfig?) {
        self.config = config
    }
}

// MARK: - TextSource + TextProtocol -
extension Text: TextProtocol {

    // MARK: Public methods
    // swiftlint:disable:next cyclomatic_complexity
    func registerViewController() -> (RegisterViewControllerTexts) -> (String) {
        return { [weak self] uiElement in
            guard let self = self else { return "" }
            if let text = self.config?.registerViewController[uiElement.rawValue] {
                return text
            }

            if uiElement == .namePlaceholder {
                return "e-mail"
            }

            if uiElement == .passwordPlaceholder {
                return "password"
            }

            if uiElement == .secondPasswordPlaceholder {
                return "password second time"
            }

            if uiElement == .authTextForButton {
                return "Log in"
            }

            if uiElement == .sighUpTextForButton {
                return "Sign up"
            }

            if uiElement == .errorPasswordLabel {
                return "Argh! Passwords dont match:("
            }

            if uiElement == .alertControllerTitle {
                return "Error!"
            }

            if uiElement == .alertControllerAuthError {
                return "Login or password is wrong. Try again:)"
            }

            if uiElement == .alertControllerSignUpError {
                return "Passwords dont match. Try again:)"
            }

            if uiElement == .alertControllerOKAction {
                return "Ok"
            }

            if uiElement == .orLabelText {
                return "or"
            }
            return ""
        }
    }

    func chatsListViewController() -> (ChatsListViewControllerTexts) -> (String) {
        return { [weak self] uiElement in
            guard let self = self else { return "" }
            if let text = self.config?.chatsListViewController[uiElement.rawValue] {
                return text
            }

            if uiElement == .title {
                return "Chat list"
            }

            return ""
        }
    }

    func profileViewController() -> (ProfileViewControllerTexts) -> (String) {
        return { [weak self] uiElement in
            guard let self = self else { return "" }
            if let text = self.config?.profileViewController[uiElement.rawValue] {
                return text
            }

            if uiElement == .title {
                return "Profile"
            }

            return ""
        }
    }
}
