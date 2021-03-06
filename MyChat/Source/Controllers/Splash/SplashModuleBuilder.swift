//
//  SplashModuleBuilder.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

final class SplashModuleBuilder {

    // MARK: - Public methods
    func build(managers: ManagerFactoryForModulesProtocol) -> SplashViewController {
        let authManager = managers.getAuthManager()
        let remoteDataBaseManager = managers.getRemoteDataBaseManager()
        let viewModel = SplashViewModel(authManager: authManager,
                                        remoteDataBaseManager: remoteDataBaseManager)
        let uiElements = SplashUI()
        let viewController = SplashViewController(viewModel: viewModel,
                                                  splashUI: uiElements)
        return viewController
    }
}
