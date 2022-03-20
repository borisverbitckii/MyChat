//
//  AppAssembly.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Foundation
import UIKit

final class AppAssembly {

    // MARK: - Init
    init(window: UIWindow) {
        let coordinator = Coordinator()
        coordinator.injectWindow(window: window)
        let managerFactory = ManagerFactory()
        let moduleFactory = ModuleFactory(coordinator: coordinator, managerFactory: managerFactory)
        coordinator.injectModuleFactory(moduleFactory: moduleFactory)

        if UserDefaults.standard.value(forKey: UserDefaultsKey.firstTimeLoad.rawValue) == nil {
            UserDefaults.standard.set(true, forKey: UserDefaultsKey.firstTimeLoad.rawValue)
            coordinator.presentRegisterViewController()
            return
        }
        coordinator.presentTabBarViewController(showSplash: true)
    }
}
