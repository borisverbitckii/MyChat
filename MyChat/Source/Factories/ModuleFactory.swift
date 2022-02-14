//
//  ModuleFactory.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Foundation
import UIKit

protocol ModuleFactoryProtocol {
    func getTabBarController() -> UITabBarController
    func getSplashModule(coordinator: CoordinatorProtocol) -> SplashViewController
    func getProfileModule(coordinator: CoordinatorProtocol) -> UINavigationController
    func getChatsListModule(coordinator: CoordinatorProtocol) -> UINavigationController
    func getChatModule(coordinator: CoordinatorProtocol) -> ChatViewController
}

final class ModuleFactory {
    
    //MARK: - Private properties
    private weak var coordinator: CoordinatorProtocol?
    private let managerFactory: ManagerFactoryProtocol
    
    //MARK: - Init
    init(coordinator: CoordinatorProtocol,
         managerFactory: ManagerFactoryProtocol) {
        self.coordinator = coordinator
        self.managerFactory = managerFactory
    }
}

//MARK: - extension + ModuleFactoryProtocol
extension ModuleFactory: ModuleFactoryProtocol {
    func getTabBarController() -> UITabBarController {
        guard let coordinator = coordinator else { return UITabBarController() }
        let chatsListVC = getChatsListModule(coordinator: coordinator)
        let profileVC = getProfileModule(coordinator: coordinator)
        let viewControllers = [chatsListVC, profileVC]
        return TabBarControllerModuleBuilder().build(coordinator: coordinator, viewControllers: viewControllers)
    }
    
    func getSplashModule(coordinator: CoordinatorProtocol) -> SplashViewController {
        SplashModuleBuilder().build(managerFactory: managerFactory,
                                    coordinator: coordinator)
    }
    
    func getProfileModule(coordinator: CoordinatorProtocol) -> UINavigationController {
        ProfileModuleBuilder().build(managerFactory: managerFactory,
                                     coordinator: coordinator)
    }
    
    func getChatsListModule(coordinator: CoordinatorProtocol) -> UINavigationController {
        return ChatsListModuleBuilder().build(managerFactory: managerFactory,
                                              coordinator: coordinator)
    }
    
    func getChatModule(coordinator: CoordinatorProtocol) -> ChatViewController {
        ChatModuleBuilder().build(managerFactory: managerFactory,
                                  coordinator: coordinator)
    }
}
