//
//  ChatsListModuleBuilder.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit

final class ChatsListModuleBuilder {
    func build(managerFactory: ManagerFactoryProtocol,
               coordinator: CoordinatorProtocol) -> UINavigationController {
        let viewModel = ChatsListViewModel(coordinator: coordinator)
        let viewController = ChatsListViewController(chatsListViewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.tabBarItem = UITabBarItem(title: "Chat List",
                                                       image: UIImage(systemName: "heart"),
                                                       selectedImage: nil)

        return navigationController
    }
}
