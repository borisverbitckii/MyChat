//
//  Text.swift
//  MyChat
//
//  Created by Борис on 13.02.2022.
//

import Foundation

enum NavigationTitleType: String {
    case chatList = "Chat list"
    case profile = "Profile"
}

enum ButtonTitleType: String {
    case register = "Sign up"
    case auth = "Log in"
}

enum PasswordPlaceholderType: String {
    case first = "Password"
    case second = "Password second time"
}

enum TextfieldType {
    case username
    case password(PasswordPlaceholderType)

    var textFieldPlaceholder: String {
        switch self {
        case .username:
            return "Login"
        case .password(let passwordPlaceholderType):
            switch passwordPlaceholderType {
            case .first:
                return "Password"
            case .second:
                return "Password second time"
            }
        }
    }
}

enum AlertControllerTitleType {
    case registrationError

    var title: String {
        switch self {
        case .registrationError:
            return "Error!"
        }
    }
}

enum AlertControllerSubtitleType {
    case authError, registerError

    var message: String {
        switch self {
        case .authError:
            return "Login or password is wrong. Try again:)"
        case .registerError:
            return "Passwords dont match. Try again:)"
        }
    }
}

enum AlertActionType: String {
    case okAction = "Ok"
}

enum Text {
    case navigationTitle(NavigationTitleType)
    case button(ButtonTitleType)
    case textfield(TextfieldType)
    case alertControllerTitle(AlertControllerTitleType)
    case alertControllerMessage(AlertControllerSubtitleType)
    case alertAction(AlertActionType)
    case passwordErrorLabel

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
        case .passwordErrorLabel:
            return "Argh! Passwords dont match:("
        }
    }
}
