//
//  SplashModuleBuilder.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

final class SplashModuleBuilder {

    // MARK: - Public methods
    func build(managers: ManagerFactoryForModulesProtocol,
               coordinator: CoordinatorProtocol) -> SplashViewController {
        let authManager = managers.getAuthManager()
        let viewModel = SplashViewModel(coordinator: coordinator,
                                        authManager: authManager)
        let viewController = SplashViewController(viewModel: viewModel)
        return viewController
    }
}
