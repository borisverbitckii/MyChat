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
        let fontsConfig = AppFontsConfig(baseFontName: "Futura Medium",
                                         buttonsFonts: ["submitButton": ("Futura Medium", 20),
                                                        "changeStateButton": ("Futura Medium", 14)],
                                         textfieldsFonts: ["registerTextfield": ("Futura Medium", 16)],
                                         labelFonts: ["registerErrorLabel": ("Futura Medium", 14)])
        // (!!!) названия элементов захардкожены в енамах 
        let fonts = Fonts(config: fontsConfig)
        let coordinator = Coordinator()
        coordinator.injectWindow(window: window)
        let managerFactory = ManagerFactory()
        let moduleFactory = ModuleFactory(coordinator: coordinator,
                                          managerFactory: managerFactory,
                                          fonts: fonts)
        coordinator.injectModuleFactory(moduleFactory: moduleFactory)

//        if UserDefaults.standard.value(forKey: UserDefaultsKey.firstTimeLoad.rawValue) == nil {
//            UserDefaults.standard.set(true, forKey: UserDefaultsKey.firstTimeLoad.rawValue)
            coordinator.presentRegisterViewController()
//            return
//        }
//
//        coordinator.presentTabBarViewController(showSplash: true)
    }
}
