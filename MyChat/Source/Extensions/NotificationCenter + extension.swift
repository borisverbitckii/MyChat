//
//  NotificationCenter + extension.swift
//  MyChat
//
//  Created by Boris Verbitsky on 18.04.2022.
//

import Foundation

extension NSNotification {
    /// Нотификация для того, чтобы уведомить, что пользователь сменил тему телефона
    static let userInterfaceStyleNotification = Notification.Name("userInterfaceStyleNotification")
    /// Нотификация для того, чтобы уведомить, что пришла новая конфигурация appConfig и тексты отличаются
    static let appConfigTextsWereUpdated = Notification.Name("appConfigTextsWereUpdated")
    /// Нотификация для того, чтобы уведомить, что пришла новая конфигурация appConfig и шрифты отличаются
    static let appConfigFontsWereUpdated = Notification.Name("appConfigFontsWereUpdated")
}
