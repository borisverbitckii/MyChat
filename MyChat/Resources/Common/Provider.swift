//
//  Provider.swift
//  MyChat
//
//  Created by Boris Verbitsky on 15.04.2022.
//

import Models
import RxSwift
import Logger

/// Базовый класс для всех провайдеров
///
/// Позволяет получить данные из plist файла и применить к локальному конфигу
class Provider <T> {

    // MARK: Public properties
    var remoteConfig: (() -> (T?))?
    lazy var localConfig: [String: Any] = {

        if T.self == Fonts.self {
            return getDataSourceDictFromPlist(resourceType: .fonts)
        }

        if T.self == Palette.self {
            return getDataSourceDictFromPlist(resourceType: .palette)
        }

        if T.self == Texts.self {
            return getDataSourceDictFromPlist(resourceType: .texts)
        }

        return [:]
    }()

    // MARK: Init
    init(remoteConfig: (() -> (T?))?) {
        self.remoteConfig = remoteConfig
    }

    // MARK: Public Methods
    func getDataSourceDictFromPlist(resourceType: ResourceType) -> [String: Any] {
        var config = [String: Any]()
        var plistName: String?

        switch resourceType {
        case .texts:
            plistName = "TextsDataSource"
        case .palette:
            plistName = "PaletteDataSource"
        case .fonts:
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
                Logger.log(to: .critical,
                           message: "Не удалось загрузить локальный репозиторий для \(String(describing: plistName))")
            }
        }
        return config
    }
}
