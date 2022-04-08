//
//  AppAssembly.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit
import RxSwift

final class AppAssembly {

    // MARK: Private Properties
    private let window: UIWindow
    private let configManager: ConfigureManagerProtocol
    private var singleDispose: Disposable?

    // MARK: Init
    init(window: UIWindow,
         configManager: ConfigureManagerProtocol) {
        self.window = window
        self.configManager = configManager
        getConfig()
    }

    // MARK: Private methods
    private func getConfig() {
        singleDispose = configManager.getConfigObserver()
            .subscribe { [configureApp] config in
                configureApp(.success(config))
            } onFailure: { [configureApp] error in
                configureApp(.failure(error))
            }
    }

    private func configureApp(_ result: Result<AppConfig, Error>) {

        var config: AppConfig?

        switch result {
        case .success(let globalConfig):
            config = globalConfig
        case .failure(let error):
            print(error)
        }

        let resource = Resource(config: config)

        let coordinator = Coordinator()
        coordinator.injectWindow(window: window)

        let managerFactory = ManagerFactory()
        let moduleFactory = ModuleFactory(coordinator: coordinator,
                                          managerFactory: managerFactory,
                                          resource: resource)
        coordinator.injectModuleFactory(moduleFactory: moduleFactory)

        //        if UserDefaults.standard.value(forKey: UserDefaultsKey.firstTimeLoad.rawValue) == nil {
        //            UserDefaults.standard.set(true, forKey: UserDefaultsKey.firstTimeLoad.rawValue)
        coordinator.presentRegisterViewController()
        //            return
        //        }
        //
        //        coordinator.presentTabBarViewController(showSplash: true)

        singleDispose?.dispose()
    }
}
