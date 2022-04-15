//
//  Resource.swift
//  MyChat
//
//  Created by Boris Verbitsky on 07.04.2022.
//

import Models
import UIKit

enum ResourceType {
    case text, color, font
}

protocol ResourceProtocol {
    var fontsProvider: FontsProviderProtocol { get }
    var textsProvider: TextProviderProtocol { get }
    var paletteProvider: PaletteProtocol { get }

}

/// Ресурсы всего приложения
///
/// Включает в себя шрифты, тексты, а также все цвета.
/// Все это устанавливается удаленно с помощью ConfigureManager,
/// но также имеет дефолтные параметры
final class Resource<T: UIViewController>: ResourceProtocol {

    // MARK: Public properties
    var fontsProvider: FontsProviderProtocol
    var textsProvider: TextProviderProtocol
    var paletteProvider: PaletteProtocol

    // MARK: Init
    init(config: AppConfig?) {
        self.fontsProvider = FontsProvider<T>(config: config?.fonts)
        self.textsProvider = TextProvider<T>(config: config?.texts)
        self.paletteProvider = Palette(config: config?.palette)
    }
}
