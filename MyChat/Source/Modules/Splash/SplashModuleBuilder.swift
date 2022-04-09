//
//  SplashModuleBuilder.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

final class SplashModuleBuilder {

    // MARK: - Public methods
    func build(managerFactory: ManagerFactoryProtocol,
               coordinator: CoordinatorProtocol) -> SplashViewController {
        let authManager = managerFactory.getAuthManager()
        let viewModel = SplashViewModel(coordinator: coordinator,
                                        authManager: authManager)
        let viewController = SplashViewController(viewModel: viewModel)
        return viewController
    }
}
