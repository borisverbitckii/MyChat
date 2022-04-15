//
//  Provider.swift
//  MyChat
//
//  Created by Boris Verbitsky on 15.04.2022.
//

import Models

/// Базовый класс для всех провайдеров
///
/// Позволяет получить данные из plist файла и применить к локальному конфигу
class Provider <T> {

    // MARK: Public properties
    let remoteConfig: T?
    lazy var localConfig: [String: Any] = {

        if T.self == AppFontsConfig.self {
            return getDataSourceDictFromPlist(resourceType: .font)
        }

        if T.self == AppPaletteConfig.self {
            return getDataSourceDictFromPlist(resourceType: .color)
        }

        if T.self == AppTextsConfig.self {
            return getDataSourceDictFromPlist(resourceType: .text)
        }

        return [:]
    }()

    // MARK: Init
    init(config: T?) {
        self.remoteConfig = config
    }

    // MARK: Public Methods
    func getDataSourceDictFromPlist(resourceType: ResourceType) -> [String: Any] {
        var config = [String: Any]()
        var plistName: String?

        switch resourceType {
        case .text:
            plistName = "TextsDataSource"
        case .color:
            plistName = "PaletteDataSource"
        case .font:
            plistName = "FontsDataSource"
        }
        if let infoPlistURL = Bundle.main.url(forResource: plistName, withExtension: "plist") {
            do {
                let textDataSourceData = try Data(contentsOf: infoPlistURL)
                if let dict = try PropertyListSerialization.propertyList(from: textDataSourceData,
                                                                         options: [],
                                                                         format: nil) as? [String: Any] {
                    config = dict
                }
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
        return config
    }
}
