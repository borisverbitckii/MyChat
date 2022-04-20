//
//  UIForViewControllers.swift
//  Models
//
//  Created by Boris Verbitsky on 17.04.2022.
//

public typealias Fonts = DataSourceForViewControllers<DataSourceForViewController<UIElementFont>>
public typealias Palette = DataSourceForViewControllers<DataSourceForViewController<UIElementColor>>
public typealias Texts = DataSourceForViewControllers<DataSourceForViewController<UIElementTexts>>

// MARK: - DataSourceForViewControllers
public struct DataSourceForViewControllers<T>: Decodable, Equatable where T: Decodable, T: Equatable  {
    public let viewControllers: [String: T]
}

// MARK: - DataSourceForViewController
public struct DataSourceForViewController<T>: Decodable, Equatable where T: Decodable, T: Equatable {
    public let uiElements: [String: T]
}

// MARK: - UIElementFont
public struct UIElementFont: Decodable, Equatable {
    public let fontName, fontSize: String
}

// MARK: - UIElementColor
public struct UIElementColor: Decodable, Equatable {
    public let lightModeHex: String
    public let darkModeHex: String
}

// MARK: - UIElementTexts
public struct UIElementTexts: Decodable, Equatable {
    public let text: String
}

