//
//  ModuleFactory.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import AsyncDisplayKit
import Models
import RxSwift

protocol ModuleFactoryProtocol {
    func getEmptyViewController() -> ASDKViewController<ASDisplayNode>
    func getTabBarController(with user: ChatUser) -> ASTabBarController
    func getRegisterViewController() -> ASDKViewController<ASDisplayNode>
    func getSplashModule(coordinator: CoordinatorProtocol) -> ASDKViewController<ASDisplayNode>
    func getProfileModule(coordinator: CoordinatorProtocol) -> ASDKNavigationController
    func getChatsListModule(coordinator: CoordinatorProtocol, user: ChatUser) -> ASDKNavigationController
    func getNewChatModule(coordinator: CoordinatorProtocol) -> ASDKViewController<ASDisplayNode>
    func getChatModule(chat: Chat, coordinator: CoordinatorProtocol) -> ASDKViewController<ASDisplayNode>
}

final class ModuleFactory {

    // MARK: - Private properties
    private weak var coordinator: CoordinatorProtocol?
    private let managerFactory: ManagerFactoryForModulesProtocol
    private let uiConfigProvider: (() -> (AppConfig))?

    // MARK: - Init
    init(coordinator: CoordinatorProtocol,
         managerFactory: ManagerFactoryForModulesProtocol,
         uiConfigProvider: (() -> (AppConfig))?) {
        self.coordinator = coordinator
        self.managerFactory = managerFactory
        self.uiConfigProvider = uiConfigProvider
    }
}

// MARK: - extension + ModuleFactoryProtocol
extension ModuleFactory: ModuleFactoryProtocol {

    func getEmptyViewController() -> ASDKViewController<ASDisplayNode> {
        EmptyViewController()
    }

    func getTabBarController(with user: ChatUser) -> ASTabBarController {
        guard let coordinator = coordinator else { return ASTabBarController()  }
        let chatsListVC = getChatsListModule(coordinator: coordinator, user: user)
        let profileVC = getProfileModule(coordinator: coordinator)
        let viewControllers = [chatsListVC, profileVC]
        return TabBarControllerModuleBuilder().build(coordinator: coordinator,
                                                     viewControllers: viewControllers)
    }

    func getRegisterViewController() -> ASDKViewController<ASDisplayNode> {
        guard let coordinator = coordinator else { return ASDKViewController() }
        let resource: ResourceProtocol = Resource<RegisterViewController>(configProvider: uiConfigProvider)
        return RegisterModuleBuilder().build(coordinator: coordinator,
                                             managers: managerFactory,
                                             fonts: resource.fontsProvider.getFont(),
                                             texts: resource.textsProvider.getText(),
                                             palette: resource.paletteProvider.getColor())
    }

    func getSplashModule(coordinator: CoordinatorProtocol) -> ASDKViewController<ASDisplayNode> {
        SplashModuleBuilder().build(managers: managerFactory,
                                    coordinator: coordinator)
    }

    func getProfileModule(coordinator: CoordinatorProtocol) -> ASDKNavigationController {
        let resource: ResourceProtocol = Resource<ProfileViewController>(configProvider: uiConfigProvider)
        return ProfileModuleBuilder().build(managers: managerFactory,
                                            coordinator: coordinator,
                                            texts: resource.textsProvider.getText(),
                                            fonts: resource.fontsProvider.getFont(),
                                            palette: resource.paletteProvider.getColor())
    }

    func getChatsListModule(coordinator: CoordinatorProtocol, user: ChatUser) -> ASDKNavigationController {
        let resource: ResourceProtocol = Resource<ChatsListViewController>(configProvider: uiConfigProvider)
        return ChatsListModuleBuilder().build(user: user,
                                              managers: managerFactory,
                                              coordinator: coordinator,
                                              texts: resource.textsProvider.getText(),
                                              fonts: resource.fontsProvider.getFont(),
                                              palette: resource.paletteProvider.getColor())
    }

    func getNewChatModule(coordinator: CoordinatorProtocol) -> ASDKViewController<ASDisplayNode> {
        NewChatModuleBuilder().build(coordinator: coordinator)
    }

    func getChatModule(chat: Chat, coordinator: CoordinatorProtocol) -> ASDKViewController<ASDisplayNode> {
        ChatModuleBuilder().build(chat: chat,
                                  managerFactory: managerFactory,
                                  coordinator: coordinator)
    }
}
