//
//  ChatsListModuleBuilder.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit
import Services

final class ChatsListModuleBuilder {

    func build(managers: ManagerFactoryProtocol,
               coordinator: CoordinatorProtocol,
               texts: @escaping (ChatsListViewControllerTexts) -> String,
               fonts: @escaping (ChatsListViewControllerFonts) -> UIFont,
               palette: @escaping (ChatsListViewControllerPalette) -> UIColor) -> UINavigationController {

        let viewModel = ChatsListViewModel(coordinator: coordinator,
                                           networkManager: managers.getNetworkManager(),
                                           fonts: fonts,
                                           texts: texts,
                                           palette: palette)
        let uiElements = ChatsListUI()
        let viewController = ChatsListViewController(uiElements: uiElements,
                                                     chatsListViewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)

        let title = texts(.title)
        navigationController.tabBarItem = UITabBarItem(title: title,
                                                       image: UIImage(systemName: "heart"),
                                                       selectedImage: nil)

        return navigationController
    }
}
