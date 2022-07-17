//
//  Resource.swift
//  MyChat
//
//  Created by Boris Verbitsky on 07.04.2022.
//

import Models
import UIKit
import RxSwift

protocol ResourceProtocol {
    var fontsProvider: FontsProviderProtocol { get }
    var textsProvider: TextProviderProtocol { get }
    var paletteProvider: PaletteProtocol { get }

}

/*

Ресурсы всего приложения

Включает в себя шрифты, тексты, а также все цвета.
Все это устанавливается удаленно с помощью ConfigureManager,
но также имеет дефолтные параметры

 */

final class Resource<T>: ResourceProtocol {

    // MARK: Public properties
    var fontsProvider: FontsProviderProtocol
    var textsProvider: TextProviderProtocol
    var paletteProvider: PaletteProtocol

    // MARK: Init
    init(configProvider: (() -> (AppConfig))?) {

        let fontsClosure: (() -> (Fonts?))? = {

            let fontsClosure: () -> (Fonts?)  = {
                configProvider?().fonts
            }
            return fontsClosure
        }()

        let textClosure: (() -> (Texts?))? = {

            let textsClosure: () -> (Texts?)  = {
                configProvider?().texts
            }
            return textsClosure
        }()

        let paletteClosure: (() -> (Palette?))? = {
            let paletteClosure: () -> (Palette?)  = {
                configProvider?().palette
            }
            return paletteClosure
        }()

        self.fontsProvider = FontsProvider<T>(remoteConfig: fontsClosure)
        self.textsProvider = TextProvider<T>(remoteConfig: textClosure)
        self.paletteProvider = PaletteProvider<T>(remoteConfig: paletteClosure)
    }
}
