//
//  AssertionErrorMessages.swift
//  MyChat
//
//  Created by Boris Verbitsky on 15.04.2022.
//

enum AssertionErrorMessages {

    case appleAuthError

    case noColor
    case noColorByHex
    case noDataForController(String)
    case noElementInPlist(String)
    case noFont(String)
    case noText(String)
    case noFontNameOrFontSize(String)

    var assertionErrorMessage: String {
        switch self {
        case .appleAuthError :
            return "`chatUser == nil` при авторизации через apple"
        case .noColor:
            return "Цвет не найдет в assets"
        case .noColorByHex:
            return "Не удалось конвертировать HEX в цвет"
        case .noDataForController(let controllerName) :
            return "Нет данных для '\(controllerName)'"
        case .noElementInPlist(let elementName):
            return "Элемента '\(elementName)' нет в plist"
        case .noFont(let elementName):
            return "Невозможно создать шрифт для '\(elementName)'"
        case .noText(let elementName):
            return "Нет текста для '\(elementName)' в plist "
        case .noFontNameOrFontSize(let elementName):
            return "Нет данных о названии или размере шрифта для '\(elementName)'"
        }
    }
}
