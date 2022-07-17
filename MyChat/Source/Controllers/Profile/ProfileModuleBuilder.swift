//
//  ProfileModuleBuilder.swift
//  MyChat
//
//  Created by Boris Verbitsky on 10.06.2022.
//

import Models
import AsyncDisplayKit

final class ProfileModuleBuilder {

    func build(source: PresenterSource,
               chatUser: ChatUser,
               coordinator: CoordinatorProtocol,
               managers: ManagerFactoryForModulesProtocol,
               texts: @escaping (ProfileViewControllerTexts) -> String,
               palette: @escaping (ProfileViewControllerPalette) -> UIColor,
               fonts: @escaping (ProfileViewControllerFonts) -> UIFont) -> ASDKViewController<ASTableNode> {
        let viewModel = ProfileViewModel(source: source,
                                         chatUser: chatUser,
                                         coordinator: coordinator,
                                         imageCacheManager: managers.getImageCacheManager(),
                                         remoteFileStorageManager: managers.getRemoteFileStorageManager(),
                                         remoteDataBaseManager: managers.getRemoteDataBaseManager(),
                                         texts: texts,
                                         palette: palette,
                                         fonts: fonts)
        let uiElements = ProfileUI()
        let viewController = ProfileViewController(viewModel: viewModel,
                                                   uiElements: uiElements)
        return viewController
    }
}
