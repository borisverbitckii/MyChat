//
//  Resource.swift
//  MyChat
//
//  Created by Boris Verbitsky on 07.04.2022.
//

import Models

protocol ResourceProtocol {
    var fonts: FontsProtocol { get }
    var texts: TextProtocol { get }
    var palette: PaletteProtocol { get }

}

final class Resource: ResourceProtocol {

    // MARK: Public properties
    var fonts: FontsProtocol
    var texts: TextProtocol
    var palette: PaletteProtocol

    // MARK: Init
    init(config: AppConfig?) {
        self.fonts = Fonts(config: config?.fonts)
        self.texts = Text(config: config?.texts)
        self.palette = Palette(config: config?.palette)
    }
}
