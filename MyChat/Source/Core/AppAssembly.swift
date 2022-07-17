//
//  AppAssembly.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit
import Models
import Logger
import RxSwift
import RxCocoa
import Services
import FirebaseCrashlytics

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
    /// Для сравнения темы, чтобы можно было обновить цвета по всему приложению в случае изменения
    private var lastUserInterfaceStyle = UIScreen.main.traitCollection.userInterfaceStyle

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

        /// Установка рутового контроллера
        let splashViewController = moduleFactory.getSplashModule()
        window.rootViewController = splashViewController
        window.makeKeyAndVisible()

        uiConfigObserverDisposable = configManager.uiConfigObserver
            .subscribe(onNext: { [weak self] appConfig in
                var notificationsNames = [Notification.Name]()

                if self?.appConfig?.texts != appConfig?.texts {
                    notificationsNames.append(NSNotification.shouldUpdateTexts)
                    Logger.log(to: .info, message: "Будет отправлено уведомление об обновлении текстов")
                }

                if self?.appConfig?.fonts != appConfig?.fonts {
                    notificationsNames.append(NSNotification.shouldUpdateFonts)
                    Logger.log(to: .info, message: "Будет отправлено уведомление об обновлении шрифтов")
                }

                if self?.lastUserInterfaceStyle != UIScreen.main.traitCollection.userInterfaceStyle {
                    self?.lastUserInterfaceStyle = UIScreen.main.traitCollection.userInterfaceStyle
                    notificationsNames.append(NSNotification.shouldUpdatePalette)
                    Logger.log(to: .info, message: "Будет отправлено уведомление об обновлении цветов в связи с изменением темы")
                } else if self?.appConfig?.palette != appConfig?.palette {
                    notificationsNames.append(NSNotification.shouldUpdatePalette)
                    Logger.log(to: .info, message: "Будет отправлено уведомление об обновлении цветов")
                }

                self?.appConfig = appConfig

                for notificationName in notificationsNames {
                    NotificationCenter.default.post(name: notificationName,
                                                    object: nil)
                }

                if self?.isInitialLoad == true {
                    splashViewController.viewModel.input.checkAuth(coordinator: coordinator)
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
                    /// Для обновления UI во всех контроллерах при смене темы
                    self?.configManager.reloadUIConfig()
                    Logger.log(to: .info, message: "Пользователь сменил тему на телефоне")
                }
            })
            .disposed(by: bag)
    }
}
