//
//  RegisterViewModel.swift
//  MyChat
//
//  Created by Борис on 14.02.2022.
//

import RxRelay

enum RegisterViewControllerState {
    case auth, register
}

protocol RegisterViewModelProtocol {
    var state: BehaviorRelay<RegisterViewControllerState> { get set }
    func presentTabBarController()
}

final class RegisterViewModel {
    
    //MARK: - Public properties
    var state = BehaviorRelay(value: RegisterViewControllerState.register)
    
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
    func presentTabBarController() {
        coordinator.presentTabBarViewController(showSplash: false)
    }
}
