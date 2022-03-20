//
//  Text.swift
//  MyChat
//
//  Created by Борис on 13.02.2022.
//

import Foundation

enum NavigationTitleType: String {
    case chatList = "Список чатов"
    case profile = "Профиль"
}

enum ButtonTitleType: String {
    case register = "Зарегистрироваться"
    case auth = "Авторизироваться"
}

enum PasswordPlaceholderType: String {
    case first = "Пароль"
    case second = "Пароль еще раз"
}

enum TextfieldType {
    case username
    case password(PasswordPlaceholderType)

    var textFieldPlaceholder: String {
        switch self {
        case .username:
            return "Имя пользователя"
        case .password(let passwordPlaceholderType):
            switch passwordPlaceholderType {
            case .first:
                return "Пароль"
            case .second:
                return "Пароль еще раз"
            }
        }
    }
}

enum AlertControllerTitleType {
    case registrationError

    var title: String {
        switch self {
        case .registrationError:
            return "Ошибка!"
        }
    }
}

enum AlertControllerSubtitleType {
    case registrationError

    var message: String {
        switch self {
        case .registrationError:
            return "Вы ввели не правильный логин или пароль. Попробуйте еще раз:)"
        }
    }
}

enum AlertActionType: String {
    case ok = "Ок"
}

enum Text {
    case navigationTitle(NavigationTitleType)
    case button(ButtonTitleType)
    case textfield(TextfieldType)
    case alertControllerTitle(AlertControllerTitleType)
    case alertControllerMessage(AlertControllerSubtitleType)
    case alertAction(AlertActionType)

    var text: String {
        switch self {
        case .navigationTitle(let navigationTitleType):
            return navigationTitleType.rawValue
        case .button(let buttonType):
            return buttonType.rawValue
        case .textfield(let textfieldType):
            return textfieldType.textFieldPlaceholder
        case .alertControllerTitle(let alertControllerTitle):
            return alertControllerTitle.title
        case .alertControllerMessage(let alertControllerMessage):
            return alertControllerMessage.message
        case .alertAction(let alertAction):
            return alertAction.rawValue
        }
    }
}
