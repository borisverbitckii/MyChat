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

enum SubmitButtonState {
    case enable, disable
}

protocol RegisterViewModelProtocol {
    var viewControllerState: BehaviorRelay<RegisterViewControllerState> { get set }
    var submitButtonState: BehaviorRelay<SubmitButtonState> { get set }
    func presentTabBarController()
    func checkTextfields(name: String?,
                         password: String?,
                         secondPassword: String?)
}

final class RegisterViewModel {
    
    //MARK: - Public properties
    var viewControllerState = BehaviorRelay(value: RegisterViewControllerState.register)
    var submitButtonState = BehaviorRelay(value: SubmitButtonState.disable)
    
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
    
    func checkTextfields(name: String?,
                         password: String?,
                         secondPassword: String?) {
        if viewControllerState.value == .register {
            (name != nil && password == secondPassword && password != "" && secondPassword != "")
            ? submitButtonState.accept(.enable)
            : submitButtonState.accept(.disable)
        } else {
            (name != "" && password != "")
            ? submitButtonState.accept(.enable)
            : submitButtonState.accept(.disable)
        }
    }
}
