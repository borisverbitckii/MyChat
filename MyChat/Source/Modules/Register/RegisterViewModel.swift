//
//  RegisterViewModel.swift
//  MyChat
//
//  Created by Борис on 14.02.2022.
//

import Foundation

protocol RegisterViewModelProtocol {
    func presentMainPage()
}

final class RegisterViewModel {
    
    //MARK: - Private properties
    private let coordinator: CoordinatorProtocol
    private let authManager: AuthManagerProtocol

    //MARK: - Init
    init(coordinator: CoordinatorProtocol,
         authManager: AuthManagerProtocol) {
        self.coordinator = coordinator
        self.authManager = authManager
    }
}

//MARK: - extension + RegisterViewModelProtocol
extension RegisterViewModel: RegisterViewModelProtocol {
    func presentMainPage() {
        coordinator.presentTabBarViewController(showSplash: false)
    }
}
