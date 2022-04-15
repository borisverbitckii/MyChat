//
//  Errors.swift
//  MyChat
//
//  Created by Boris Verbitsky on 08.04.2022.
//

enum Errors: Swift.Error, LocalizedError {
    case elementWithoutText
    case cantCheckIsLoggedInOrNot

    var localizedDescription: String {
        switch self {
        case .elementWithoutText:
            return "Инициализирован UI элемент, у которого нет текста"
        case .cantCheckIsLoggedInOrNot:
            return "Невозможно поверить, залогинен ли пользователь или нет"
        }
    }
}
