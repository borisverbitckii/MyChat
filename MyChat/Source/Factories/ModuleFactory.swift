//
//  ModuleFactory.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit
import Models

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
    private let config: AppConfig?

    // MARK: - Init
    init(coordinator: CoordinatorProtocol,
         managerFactory: ManagerFactoryProtocol,
         config: AppConfig? = nil) {
        self.coordinator = coordinator
        self.managerFactory = managerFactory
        self.config = config
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
        let resource = Resource<RegisterViewController>(config: config)
        return RegisterModuleBuilder().build(coordinator: coordinator,
                                             managers: managerFactory,
                                             fonts: resource.fontsProvider.getFont(),
                                             texts: resource.textsProvider.getText(),
                                             palette: resource.paletteProvider.getColor())
    }

    func getSplashModule(coordinator: CoordinatorProtocol) -> SplashViewController {
        SplashModuleBuilder().build(managers: managerFactory,
                                    coordinator: coordinator)
    }

    func getProfileModule(coordinator: CoordinatorProtocol) -> UINavigationController {
        let resource = Resource<ProfileViewController>(config: config)
        return ProfileModuleBuilder().build(managers: managerFactory,
                                            coordinator: coordinator,
                                            texts: resource.textsProvider.getText(),
                                            fonts: resource.fontsProvider.getFont(),
                                            palette: resource.paletteProvider.getColor())
    }

    func getChatsListModule(coordinator: CoordinatorProtocol) -> UINavigationController {
        let resource = Resource<ChatsListViewController>(config: config)
        return ChatsListModuleBuilder().build(managers: managerFactory,
                                              coordinator: coordinator,
                                              texts: resource.textsProvider.getText(),
                                              fonts: resource.fontsProvider.getFont(),
                                              palette: resource.paletteProvider.getColor())
    }

    func getNewChatModule(coordinator: CoordinatorProtocol) -> NewChatViewController {
        NewChatModuleBuilder().build(coordinator: coordinator)
    }

    func getChatModule(coordinator: CoordinatorProtocol) -> ChatViewController {
        ChatModuleBuilder().build(managerFactory: managerFactory,
                                  coordinator: coordinator)
    }
}
