//
//  PorfileViewModel.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Foundation
import RxSwift
import Services

enum ProfileViewControllerState {
    case normal, edit
}

protocol ProfileViewModelProtocol {
    var input: ProfileViewModelInputProtocol { get }
    var output: ProfileViewModelOutputProtocol { get }
}

protocol ProfileViewModelInputProtocol {
    func signOut()
}

protocol ProfileViewModelOutputProtocol {
    var state: ProfileViewControllerState { get set }
}

final class ProfileViewModel {

    // MARK: - Public properties
    var input: ProfileViewModelInputProtocol { return self }
    var output: ProfileViewModelOutputProtocol { return self }

    var state: ProfileViewControllerState = .normal

    // MARK: - Private properties
    private let coordinator: CoordinatorProtocol
    private let authManager: AuthManagerProfileProtocol
    private let disposeBag = DisposeBag()

    // MARK: - Init
    init(coordinator: CoordinatorProtocol,
         authManager: AuthManagerProfileProtocol) {
        self.coordinator = coordinator
        self.authManager = authManager
    }

}

// MARK: - extension + ProfileViewModelProtocol
extension ProfileViewModel: ProfileViewModelProtocol {

}

// MARK: - extension + ProfileViewModelInputProtocol
extension ProfileViewModel: ProfileViewModelInputProtocol {
    func signOut() {
        authManager.signOut()
            .subscribe { [coordinator] _ in
                coordinator.presentRegisterViewController()
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - extension + ProfileViewModelOutputProtocol
extension ProfileViewModel: ProfileViewModelOutputProtocol {

}
