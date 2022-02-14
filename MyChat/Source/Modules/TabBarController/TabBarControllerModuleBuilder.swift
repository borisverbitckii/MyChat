//
//  TabBarControllerModuleBuilder.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit

final class TabBarControllerModuleBuilder {
    func build(coordinator: CoordinatorProtocol,
               viewControllers: [UIViewController]) -> TabBarController {
        let tabBarViewModel = TabBarControllerViewModel(coordinator: coordinator)
        let tabBarController = TabBarController(tabBarViewModel: tabBarViewModel)
        tabBarController.viewControllers = viewControllers
        return tabBarController
    }
}
