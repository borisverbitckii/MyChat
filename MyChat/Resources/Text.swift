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
}

enum Text {
    case title(NavigationTitleType)
    case button(ButtonTitleType)
    
    var text: String {
        switch self {
        case .title(let navigationTitleType):
            return navigationTitleType.rawValue
        case .button(let buttonType):
            return buttonType.rawValue
        }
    }
}
