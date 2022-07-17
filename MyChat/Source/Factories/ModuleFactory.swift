//
//  ModuleFactory.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Models
import RxSwift
import AsyncDisplayKit

protocol ModuleFactoryProtocol {
    func getSplashModule() -> SplashViewController
    func getRegisterViewController() -> ASDKViewController<ASDisplayNode>
    func getProfileViewController(source: PresenterSource, chatUser: ChatUser) -> ASDKViewController<ASTableNode>
    func getSettingsModule(chatUser: ChatUser,
                           coordinator: CoordinatorProtocol) -> ASDKViewController<ASDisplayNode>
    func getChatsListModule(coordinator: CoordinatorProtocol, user: ChatUser) -> ASDKNavigationController
    func getNewChatModule(coordinator: CoordinatorProtocol,
                          presentingViewController: TransitionHandler) -> ASDKViewController<ASDisplayNode>
    func getChatModule(receiverUser: ChatUser,
                       coordinator: CoordinatorProtocol) -> ASDKViewController<ASDisplayNode>
    func getImagePickerController(delegatе: UIImagePickerControllerDelegate  & UINavigationControllerDelegate,
                                  source: UIImagePickerController.SourceType) -> UIImagePickerController
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

    func getSplashModule() -> SplashViewController {
        SplashModuleBuilder().build(managers: managerFactory)
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

    func getProfileViewController(source: PresenterSource, chatUser: ChatUser) -> ASDKViewController<ASTableNode> {
        guard let coordinator = coordinator else { return ASDKViewController() }
        let resource: ResourceProtocol = Resource<ProfileViewController>(configProvider: uiConfigProvider)
        return ProfileModuleBuilder().build(source: source,
                                            chatUser: chatUser,
                                            coordinator: coordinator,
                                            managers: managerFactory,
                                            texts: resource.textsProvider.getText(),
                                            palette: resource.paletteProvider.getColor(),
                                            fonts: resource.fontsProvider.getFont())
    }

    func getSettingsModule(chatUser: ChatUser,
                           coordinator: CoordinatorProtocol) -> ASDKViewController<ASDisplayNode> {
        let resource: ResourceProtocol = Resource<SettingsViewController>(configProvider: uiConfigProvider)
        return SettingsModuleBuilder().build(chatUser: chatUser,
                                             managers: managerFactory,
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
                                            palette: resource.paletteProvider.getColor(),
                                            fonts: resource.fontsProvider.getFont())
    }

    func getChatModule(receiverUser: ChatUser, coordinator: CoordinatorProtocol) -> ASDKViewController<ASDisplayNode> {
        let resource: ResourceProtocol = Resource<ChatViewController>(configProvider: uiConfigProvider)
        return ChatModuleBuilder().build(receiverUser: receiverUser,
                                         managerFactory: managerFactory,
                                         coordinator: coordinator,
                                         texts: resource.textsProvider.getText(),
                                         palette: resource.paletteProvider.getColor(),
                                         fonts: resource.fontsProvider.getFont())
    }

    func getImagePickerController(delegatе: UIImagePickerControllerDelegate  & UINavigationControllerDelegate,
                                  source: UIImagePickerController.SourceType) -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = source
        imagePickerController.allowsEditing = false
        imagePickerController.delegate = delegatе
        return imagePickerController
    }
}
