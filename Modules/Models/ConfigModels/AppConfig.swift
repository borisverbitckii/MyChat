//
//  AppConfig.swift
//  MyChat
//
//  Created by Boris Verbitsky on 07.04.2022.
//

public struct AppConfig {
    public let fonts: Fonts?
    public let texts: Texts?
    public let palette: Palette?

    public init(fonts: Fonts?,
                texts: Texts?,
                palette: Palette?) {
        self.fonts = fonts
        self.texts = texts
        self.palette = palette
    }
}
