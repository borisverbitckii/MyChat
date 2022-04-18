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

    // MARK: Private Properties
    private let window: UIWindow

    private let configManager: ConfigureManagerProtocol
    /// Для того, чтобы избавиться от дублирования запроса на обновление ui конфига
    private var isInitialLoad = true
    private let bag = DisposeBag()

    // MARK: Init
    init(window: UIWindow,
         configManager: ConfigureManagerProtocol) {
        self.window = window
        self.configManager = configManager

        configureApp()
        observeUserInterfaceStyle()
    }

    // MARK: Private methods
    private func configureApp() {
        let coordinator: CoordinatorProtocol = Coordinator(window: window)
        let managerFactory: ManagerFactoryProtocol = ManagerFactory()

        uiConfigObserverDisposable = configManager.uiConfigObserver
            .subscribe(onNext: { [weak self] appConfig in

                let appConfigClosure: () -> AppConfig = {
                    let appConfigClosure = {
                        appConfig ?? AppConfig(fonts: nil, texts: nil, palette: nil)
                    }
                    return appConfigClosure
                }()

                let moduleFactory: ModuleFactoryProtocol = ModuleFactory(coordinator: coordinator,
                                                                         managerFactory: managerFactory,
                                                                         uiConfigProvider: appConfigClosure)

                coordinator.injectModuleFactory(moduleFactory: moduleFactory)
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
                    // Для обновления UI во всех контроллерах
                    self?.configManager.reloadUIConfig {
                        NotificationCenter.default.post(name: NSNotification.userInterfaceStyleNotification,
                                                        object: nil)
                    }
                }
            })
            .disposed(by: bag)
    }
}
