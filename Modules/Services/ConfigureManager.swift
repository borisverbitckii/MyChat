//
//  ConfigureManager.swift
//  MyChat
//
//  Created by Boris Verbitsky on 05.04.2022.
//

import RxSwift
import Models

public protocol ConfigureManagerProtocol {
    func getConfigObserver() -> Single<AppConfig>
}

public final class ConfigureManager {

    // MARK: Init
    public init() {}

}

// MARK: - ConfigureManager + ConfigureManagerProtocol -
extension ConfigureManager: ConfigureManagerProtocol {

    // MARK: Public methods
    public func getConfigObserver() -> Single<AppConfig> {
        typealias RegisterFonts = [String : (fontName: String, fontSize: CGFloat)]

        // Для примера
        let registerViewController: RegisterFonts  = ["submitButton": (fontName: "Futura Medium", fontSize: 20),
                                                      "changeStateButton": (fontName: "Futura Medium", fontSize: 14),
                                                      "registerTextfield": (fontName: "Futura Medium", fontSize: 16),
                                                      "registerErrorLabel": (fontName: "Futura Medium", fontSize: 14),
                                                      "registerOrLabel": (fontName: "Futura Medium", fontSize: 24)]

        let fontsConfig = AppFontsConfig(baseFontName: "Futura Medium",
                                         registerViewController: registerViewController,
                                         chatsListViewController: [:],
                                         profileViewController: [:])

        let textConfig = AppTextsConfig(registerViewController: [:],
                                            chatsListViewController: [:],
                                            profileViewController: [:])

        let paletteConfig = AppPaletteConfig(registerViewController: [:],
                                             chatsListViewController: [:],
                                             profileViewController: [:])

        let config = AppConfig(fonts: fontsConfig,
                               texts: textConfig,
                               palette: paletteConfig)

        return Single<AppConfig>.create { obs in
                obs(.success(config))
//                obs(.failure(NSError())) // для ошибки при подключении к удаленному конфигу
            return Disposables.create()
        }
        .subscribe(on: SerialDispatchQueueScheduler(internalSerialQueueName: "configQueue"))
        .observe(on: MainScheduler.instance)
    }
}
