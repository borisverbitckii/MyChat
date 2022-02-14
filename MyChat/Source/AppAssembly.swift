//
//  AppAssembly.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Foundation
import UIKit

final class AppAssembly {

    //MARK: - Init
    init(window: UIWindow) {
        let coordinator = Coordinator()
        coordinator.injectWindow(window: window)
        let managerFactory = ManagerFactory()
        let moduleFactory = ModuleFactory(coordinator: coordinator, managerFactory: managerFactory)
        coordinator.injectModuleFactory(moduleFactory: moduleFactory)
        coordinator.presentTabBarViewController()
    }
}
