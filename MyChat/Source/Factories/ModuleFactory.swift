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
    func getTabBarController(with user: ChatUser) -> ASTabBarController
    func getRegisterViewController() -> ASDKViewController<ASDisplayNode>
    func getSplashModule() -> SplashViewController
    func getProfileModule(coordinator: CoordinatorProtocol) -> ASDKNavigationController
    func getChatsListModule(coordinator: CoordinatorProtocol, user: ChatUser) -> ASDKNavigationController
    func getNewChatModule(coordinator: CoordinatorProtocol,
                          presentingViewController: TransitionHandler) -> ASDKViewController<ASDisplayNode>
    func getChatModule(receiverUser: ChatUser,
                       coordinator: CoordinatorProtocol) -> ASDKViewController<ASDisplayNode>
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

    func getSplashModule() -> SplashViewController {
        SplashModuleBuilder().build(managers: managerFactory)
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

    func getNewChatModule(coordinator: CoordinatorProtocol,
                          presentingViewController: TransitionHandler) -> ASDKViewController<ASDisplayNode> {
        let resource: ResourceProtocol = Resource<NewChatViewController>(configProvider: uiConfigProvider)
        return NewChatModuleBuilder().build(coordinator: coordinator, presentingViewController: presentingViewController,
                                            managers: managerFactory,
                                            texts: resource.textsProvider.getText(),
                                            palette: resource.paletteProvider.getColor())
    }

    func getChatModule(receiverUser: ChatUser, coordinator: CoordinatorProtocol) -> ASDKViewController<ASDisplayNode> {
        ChatModuleBuilder().build(receiverUser: receiverUser,
                                  managerFactory: managerFactory,
                                  coordinator: coordinator)
    }
}
