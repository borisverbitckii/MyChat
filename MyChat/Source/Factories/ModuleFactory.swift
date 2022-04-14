//
//  ModuleFactory.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit

protocol ModuleFactoryProtocol {
    func getTabBarController() -> UITabBarController
    func getRegisterViewController() -> UIViewController
    func getSplashModule(coordinator: CoordinatorProtocol) -> SplashViewController
    func getProfileModule(coordinator: CoordinatorProtocol) -> UINavigationController
    func getChatsListModule(coordinator: CoordinatorProtocol) -> UINavigationController
    func getNewChatModule(coordinator: CoordinatorProtocol) -> NewChatViewController
    func getChatModule(coordinator: CoordinatorProtocol) -> ChatViewController
}

final class ModuleFactory {

    // MARK: - Private properties
    private weak var coordinator: CoordinatorProtocol?
    private let managerFactory: ManagerFactoryProtocol
    private let resource: ResourceProtocol

    // MARK: - Init
    init(coordinator: CoordinatorProtocol,
         managerFactory: ManagerFactoryProtocol,
         resource: ResourceProtocol) {
        self.coordinator = coordinator
        self.managerFactory = managerFactory
        self.resource = resource
    }
}

// MARK: - extension + ModuleFactoryProtocol
extension ModuleFactory: ModuleFactoryProtocol {
    func getTabBarController() -> UITabBarController {
        guard let coordinator = coordinator else { return UITabBarController() }
        let chatsListVC = getChatsListModule(coordinator: coordinator)
        let profileVC = getProfileModule(coordinator: coordinator)
        let viewControllers = [chatsListVC, profileVC]
        return TabBarControllerModuleBuilder().build(coordinator: coordinator,
                                                     viewControllers: viewControllers)
    }

    func getRegisterViewController() -> UIViewController {
        guard let coordinator = coordinator else { return UIViewController() }
        return RegisterModuleBuilder().build(coordinator: coordinator,
                                             managers: managerFactory,
                                             fonts: resource.fonts.registerViewController(),
                                             texts: resource.texts.registerViewController(),
                                             palette: resource.palette.registerViewController())
    }

    func getSplashModule(coordinator: CoordinatorProtocol) -> SplashViewController {
        SplashModuleBuilder().build(managers: managerFactory,
                                    coordinator: coordinator)
    }

    func getProfileModule(coordinator: CoordinatorProtocol) -> UINavigationController {
        ProfileModuleBuilder().build(managers: managerFactory,
                                     coordinator: coordinator,
                                     texts: resource.texts.profileViewController(),
                                     fonts: resource.fonts.profileViewController(),
                                     palette: resource.palette.profileViewController())
    }

    func getChatsListModule(coordinator: CoordinatorProtocol) -> UINavigationController {
        ChatsListModuleBuilder().build(managers: managerFactory,
                                              coordinator: coordinator,
                                       fonts: resource.fonts.chatsListViewController(),
                                       texts: resource.texts.chatsListViewController(),
                                       palette: resource.palette.chatsListViewController())
    }

    func getNewChatModule(coordinator: CoordinatorProtocol) -> NewChatViewController {
        NewChatModuleBuilder().build(coordinator: coordinator)
    }

    func getChatModule(coordinator: CoordinatorProtocol) -> ChatViewController {
        ChatModuleBuilder().build(managerFactory: managerFactory,
                                  coordinator: coordinator)
    }
}
