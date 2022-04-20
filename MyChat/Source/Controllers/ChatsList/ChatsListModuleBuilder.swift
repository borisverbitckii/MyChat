//
//  ChatsListModuleBuilder.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import AsyncDisplayKit
import Services

final class ChatsListModuleBuilder {

    func build(managers: ManagerFactoryForModulesProtocol,
               coordinator: CoordinatorProtocol,
               texts: @escaping (ChatsListViewControllerTexts) -> String,
               fonts: @escaping (ChatsListViewControllerFonts) -> UIFont,
               palette: @escaping (ChatsListViewControllerPalette) -> UIColor) -> ASDKNavigationController {

        let viewModel = ChatsListViewModel(coordinator: coordinator,
                                           networkManager: managers.getNetworkManager(),
                                           fonts: fonts,
                                           texts: texts,
                                           palette: palette)
        let uiElements = ChatsListUI()
        let viewController = ChatsListViewController(uiElements: uiElements,
                                                     chatsListViewModel: viewModel)
        let navigationController = ASDKNavigationController(rootViewController: viewController)

        let title = texts(.title)
        navigationController.tabBarItem = UITabBarItem(title: title,
                                                       image: UIImage(systemName: "heart"),
                                                       selectedImage: nil)

        return navigationController
    }
}
