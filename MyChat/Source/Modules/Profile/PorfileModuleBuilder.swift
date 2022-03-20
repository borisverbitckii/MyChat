//
//  PorfileModuleBuilder.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit

final class ProfileModuleBuilder {

    func build(managerFactory: ManagerFactoryProtocol,
               coordinator: CoordinatorProtocol) -> UINavigationController {
        let viewModel = ProfileViewModel(coordinator: coordinator)
        let viewController = ProfileViewController(profileViewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.tabBarItem = UITabBarItem(title: "Pofile", image: UIImage(systemName: "heart"), selectedImage: nil) // change image
        return navigationController
    }
}
