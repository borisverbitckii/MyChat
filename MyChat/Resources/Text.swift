//
//  Text.swift
//  MyChat
//
//  Created by Борис on 13.02.2022.
//

import Models

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
    // swiftlint:disable:next function_body_length cyclomatic_complexity
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

            if uiElement == .errorLabelPasswordsNotTheSame {
                return "Passwords don't match"
            }

            if uiElement == .errorLabelEmailInvalid {
                return "Not correct e-mail"
            }

            if uiElement == .alertControllerInvalidPassword {
                return "Password is not valid. It should be 6+ symbols"
            }

            if uiElement == .errorLabelPasswordInvalid {
                return "Password should be 6+ symbols"
            }

            if uiElement == .alertControllerTitle {
                return "Error!"
            }

            if uiElement == .alertControllerAuthError {
                return "Login or password is wrong. Try again:)"
            }

            if uiElement == .alertControllerGoogleAuthError {
                return "Something wrong with Google sign in. Please try another way to log in"
            }

            if uiElement == .alertControllerAppleAuthError {
                return "Something wrong with Apple sign in. Please try another way to log in"
            }

            if uiElement == .alertControllerFacebookAuthError {
                return "Something wrong with Facebook sign in. Please try another way to log in"
            }

            if uiElement == .alertControllerSignUpError {
                return "Passwords don't match. Try again:)"
            }

            if uiElement == .alertControllerInvalidEmail {
                return "Email is invalid, please try again"
            }

            if uiElement == .alertControllerIsAlreadySignUp {
                return "Account with this email is already signed up"
            }

            if uiElement == .alertControllerOKAction {
                return "Ok"
            }

            if uiElement == .orLabelText {
                return "or"
            }

            assertionFailure("Случился кейс, в котором не назначен текст для ui элемента")
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
            assertionFailure("Случился кейс, в котором не назначен текст для ui элемента")
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

            assertionFailure("Случился кейс, в котором не назначен текст для ui элемента")
            return ""
        }
    }
}
