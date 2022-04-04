//
//  RegisterBuilder.swift
//  MyChat
//
//  Created by Борис on 14.02.2022.
//

import UIKit

final class RegisterModuleBuilder {
    func build(coordinator: CoordinatorProtocol,
               authManager: AuthManagerProtocol,
               fonts: FontsProtocol) -> RegisterViewController {
        let viewModel = RegisterViewModel(coordinator: coordinator,
                                          authManager: authManager,
                                          fonts: fonts)
        let viewController = RegisterViewController(registerViewModel: viewModel)
        return viewController
    }
}
