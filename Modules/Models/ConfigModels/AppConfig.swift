//
//  AppConfig.swift
//  MyChat
//
//  Created by Boris Verbitsky on 07.04.2022.
//

public struct AppConfig {
    public let fonts: AppFontsConfig
    public let texts: AppTextsConfig
    public let palette: AppPaletteConfig

    public init(fonts: AppFontsConfig,
                texts: AppTextsConfig,
                palette: AppPaletteConfig) {
        self.fonts = fonts
        self.texts = texts
        self.palette = palette
    }
}
