//
//  SettingsModuleBuilder.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Models
import AsyncDisplayKit

final class SettingsModuleBuilder {

    func build(chatUser: ChatUser,
               managers: ManagerFactoryForModulesProtocol,
               coordinator: CoordinatorProtocol,
               texts: @escaping (SettingsViewControllerTexts) -> String,
               fonts: @escaping (SettingsViewControllerFonts) -> UIFont,
               palette: @escaping (SettingsViewControllerPalette) -> UIColor) -> ASDKViewController<ASDisplayNode> {
        let viewModel = SettingsViewModel(chatUser: chatUser,
                                          coordinator: coordinator,
                                          authManager: managers.getAuthManager(),
                                          storageManager: managers.getStorageManager(),
                                          remoteDataBaseManager: managers.getRemoteDataBaseManager(),
                                          webSocketsFacade: managers.getWebSocketsFlowFacade(),
                                          texts: texts,
                                          fonts: fonts,
                                          palette: palette)
        let uiElements = SettingsUI()
        return SettingsViewController(settingsViewModel: viewModel,
                                      uiElements: uiElements)
    }
}
