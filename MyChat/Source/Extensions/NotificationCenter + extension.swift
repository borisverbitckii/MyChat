//
//  NotificationCenter + extension.swift
//  MyChat
//
//  Created by Boris Verbitsky on 18.04.2022.
//

import Foundation

extension NSNotification {
    /// Нотификация для того, чтобы уведомить, что пришла новая конфигурация appConfig и цвета отличаются
    static let shouldUpdatePalette = Notification.Name("appConfigPaletteWasUpdated")
    /// Нотификация для того, чтобы уведомить, что пришла новая конфигурация appConfig и тексты отличаются
    static let shouldUpdateFonts = Notification.Name("appConfigTextsWereUpdated")
    /// Нотификация для того, чтобы уведомить, что пришла новая конфигурация appConfig и шрифты отличаются
    static let shouldUpdateTexts = Notification.Name("appConfigFontsWereUpdated")

}
