//
//  RegisterConstants.swift
//  MyChat
//
//  Created by Boris Verbitsky on 08.04.2022.
//

import UIKit

// Все константы для верстки вынесены отдельно
struct RegisterConstants {

    // MARK: Public properties
    /// Текстфилды
    let textfieldsStackSpacing: CGFloat = 20
    let stackElementSize = CGSize(width: 260, height: 40)
    // swiftlint:disable:next identifier_name
    let textfieldsStackTopInsetForPhonesWithoutHomeButton: CGFloat = 280
    // swiftlint:disable:next identifier_name
    let textfieldsStackTopInsetForPhonesWithHomeButton: CGFloat = 310
    let passwordSecondTimeTextfieldAlphaEnable: CGFloat = 1
    let passwordSecondTimeTextfieldAlphaDisable: CGFloat = 0
    /// Кнопки
    let buttonsSize = CGSize(width: 250, height: 40)
    /// Ссылки
    let agreementsSpacing: CGFloat = 40
    /// SafeAreaInsets
    let bottomInsetForPhonesWithoutHomeButton: CGFloat = 32
    let bottomInsetForPhonesWithHomeButton: CGFloat = 16
    /// Время анимации
    let animationDurationForColors: TimeInterval = 0.25
    let animationDurationForErrorLabel: TimeInterval = 0.15
    let animationDurationForActivityIndicator: TimeInterval = 0.3
}
