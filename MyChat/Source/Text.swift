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

enum Text {
    case title(NavigationTitleType)
    
    var text: String {
        switch self {
        case .title(let navigationTitleType):
            return navigationTitleType.rawValue
        }
    }
}
