//
//  RegisterBuilder.swift
//  MyChat
//
//  Created by Борис on 14.02.2022.
//

import UIKit
import Services

final class RegisterModuleBuilder {
    func build(coordinator: CoordinatorProtocol,
               managers: ManagerFactoryForModulesProtocol,
               fonts: @escaping (RegisterViewControllerFonts) -> UIFont,
               texts: @escaping  (RegisterViewControllerTexts) -> String,
               palette: @escaping (RegisterViewControllerPalette) -> UIColor) -> RegisterViewController {
        let uiElements = RegisterUI()
        let viewModel = RegisterViewModel(coordinator: coordinator,
                                          authFacade: managers.getAuthFacade(),
                                          fonts: fonts,
                                          texts: texts,
                                          palette: palette)
        let viewController = RegisterViewController(uiElements: uiElements,
                                                    registerViewModel: viewModel,
                                                    constants: RegisterConstants())
        return viewController
    }
}
