//
//  PorfileModuleBuilder.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import AsyncDisplayKit

final class ProfileModuleBuilder {

    func build(managers: ManagerFactoryForModulesProtocol,
               coordinator: CoordinatorProtocol,
               texts: @escaping (ProfileViewControllerTexts) -> String,
               fonts: @escaping (ProfileViewControllerFonts) -> UIFont,
               palette: @escaping (ProfileViewControllerPalette) -> UIColor) -> ASDKNavigationController {
        let viewModel = ProfileViewModel(coordinator: coordinator,
                                         authManager: managers.getAuthManager(),
                                         texts: texts,
                                         fonts: fonts,
                                         palette: palette)
        let viewController = ProfileViewController(profileViewModel: viewModel)
        let navigationController = ASDKNavigationController(rootViewController: viewController)
        navigationController.tabBarItem = UITabBarItem(title: "Pofile",
                                                       image: UIImage(systemName: "heart"),
                                                       selectedImage: nil) // change image
        return navigationController
    }
}
