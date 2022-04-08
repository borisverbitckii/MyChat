//
//  ChatsListModuleBuilder.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit

final class ChatsListModuleBuilder {

    func build(managerFactory: ManagerFactoryProtocol,
               coordinator: CoordinatorProtocol,
               networkManager: NetworkManagerChatListProtocol,
               fonts: @escaping (ChatsListViewControllerFonts) -> UIFont,
               texts: @escaping (ChatsListViewControllerTexts) -> String) -> UINavigationController {

        let viewModel = ChatsListViewModel(coordinator: coordinator,
                                           networkManager: networkManager,
                                           fonts: fonts,
                                           texts: texts)
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
