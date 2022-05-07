//
//  ConfigureManager.swift
//  MyChat
//
//  Created by Boris Verbitsky on 05.04.2022.
//

import Models
import Logger
import RxSwift
import RxRelay
import FirebaseRemoteConfig

private enum UIConfigType: String {
    case fonts, texts, palette
}

public protocol ConfigureManagerProtocol {
    var uiConfigObserver: PublishRelay<AppConfig?> { get }
    func reloadUIConfig()
}

public final class ConfigureManager {

    // MARK: Public properties
    public let uiConfigObserver = PublishRelay<AppConfig?>()

    // MARK: Private properties
    private let remoteConfig = RemoteConfig.remoteConfig()

    // MARK: Init
    public init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        // TODO: Стереть при релизе, чтобы не было куча запросов (будет означать сколько в кэше держит инфу)
        remoteConfig.configSettings = settings
        reloadUIConfig()
    }
}

// MARK: - ConfigureManager + ConfigureManagerProtocol -
extension ConfigureManager: ConfigureManagerProtocol {

    // MARK: Public methods
    public func reloadUIConfig() {
        remoteConfig.fetchAndActivate { [weak self] status, error in
            guard let self = self else { return }
            if let error = error {
                Logger.log(to: .error,
                           message: "Не удалось скачать удаленный конфиг",
                           error: error)
                self.uiConfigObserver.accept(nil)
                return
            }

            var fontsConfig: Fonts?
            var paletteConfig: Palette?
            var textConfig: Texts?

            if status != .error {
                fontsConfig = self.getConfig(with: .fonts)
                paletteConfig = self.getConfig(with: .palette)
                textConfig = self.getConfig(with: .texts)
            }

            let config = AppConfig(fonts: fontsConfig,
                                   texts: textConfig,
                                   palette: paletteConfig)
            self.uiConfigObserver.accept(config)
        }
    }

    // MARK: Private methods
    private func decode<T: Decodable>(jsonData: Data) -> T? {
        do {
            return try JSONDecoder().decode(T.self, from: jsonData)
        } catch {
            Logger.log(to: .error,
                       message: "Не удалось декодировать удаленный конфиг",
                       error: error)
            return nil
        }
    }

    private func getConfig<T: Decodable>(with type: UIConfigType) -> T? {
        let fontsJSON = remoteConfig[type.rawValue].dataValue
        return decode(jsonData: fontsJSON)
    }
}
