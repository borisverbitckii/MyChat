//
//  RegisterBuilder.swift
//  MyChat
//
//  Created by Борис on 14.02.2022.
//

import UIKit

final class RegisterModuleBuilder {
    func build(coordinator: CoordinatorProtocol,
               authManager: AuthManagerRegisterProtocol,
               fonts: @escaping (RegisterViewControllerFonts) -> UIFont,
               texts: @escaping  (RegisterViewControllerTexts) -> String,
               palette: @escaping (RegisterViewControllerPalette) -> UIColor) -> RegisterViewController {

        let uiElements = RegisterUI(palette: palette)
        let viewModel = RegisterViewModel(coordinator: coordinator,
                                          authManager: authManager,
                                          fonts: fonts,
                                          texts: texts,
                                          palette: palette)
        let viewController = RegisterViewController(uiElements: uiElements,
                                                    registerViewModel: viewModel,
                                                    constants: RegisterConstants())
        return viewController
    }
}
