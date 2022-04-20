//
//  AppAssembly.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit
import RxSwift
import RxCocoa
import Models
import Services

final class AppAssembly {

    // MARK: Public properties
    /// Подписка на обновление ui конфига, выгружается из памяти в appDelegate
    var uiConfigObserverDisposable: Disposable?
    var pushNotificationHandler: (() -> Void)?

    // MARK: Private Properties
    private let window: UIWindow
    private let bag = DisposeBag()

    private let configManager: ConfigureManagerProtocol
    /// Для того, чтобы избавиться от дублирования запроса на обновление ui конфига
    private var isInitialLoad = true
    /// Конфиг для обновления приложения, автоматически захватывается клоужером
    private var appConfig: AppConfig?

    // MARK: Init
    init(window: UIWindow,
         configManager: ConfigureManagerProtocol) {
        self.window = window
        self.configManager = configManager

        configureApp()
        observeUserInterfaceStyle()

        pushNotificationHandler = {
            configManager.reloadUIConfig()
        }
    }

    // MARK: Private methods
    private func configureApp() {
        let coordinator: CoordinatorProtocol = Coordinator(window: window)
        let managerFactory: ManagerFactoryForModulesProtocol = ManagerFactory()

        let appConfigClosure: () -> AppConfig = {
            let appConfigClosure = {
                self.appConfig ?? AppConfig(fonts: nil, texts: nil, palette: nil)
            }
            return appConfigClosure
        }()

        let moduleFactory: ModuleFactoryProtocol = ModuleFactory(coordinator: coordinator,
                                                                 managerFactory: managerFactory,
                                                                 uiConfigProvider: appConfigClosure)
        coordinator.injectModuleFactory(moduleFactory: moduleFactory)

        uiConfigObserverDisposable = configManager.uiConfigObserver
            .subscribe(onNext: { [weak self] appConfig in
                self?.appConfig = appConfig

                // Постит нотификацию только при изменении текстов
                if self?.appConfig?.texts != appConfig?.texts && self?.appConfig != nil {
                    NotificationCenter.default.post(name: NSNotification.appConfigTextsWereUpdated,
                                                    object: nil)
                }

                // Постит нотификацию только при изменении шрифтов
                if self?.appConfig?.fonts != appConfig?.fonts && self?.appConfig != nil {
                    NotificationCenter.default.post(name: NSNotification.appConfigFontsWereUpdated,
                                                    object: nil)
                }

                // Постит нотификацию цветов каждый раз, когда она прилетает
                NotificationCenter.default.post(name: NSNotification.userInterfaceStyleNotification,
                                                object: nil)
                if self?.isInitialLoad == true {
                    coordinator.presentSplashViewController()
                    self?.isInitialLoad = false
                }
            })
    }

    /// Метод, для того, чтобы подписаться на изменения темы телефона
    private func observeUserInterfaceStyle() {
        UIScreen.main.rx
            .userInterfaceStyle()
            .subscribe(onNext: { [weak self] _ in
                if self?.isInitialLoad == false {
                    // Для обновления UI во всех контроллерах при смене темы
                    self?.configManager.reloadUIConfig()
                }
            })
            .disposed(by: bag)
    }
}
