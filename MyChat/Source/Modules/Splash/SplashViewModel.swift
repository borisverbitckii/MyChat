//
//  SplashViewModel.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit
import RxRelay
import RxSwift
import FirebaseAuth

protocol SplashViewModelProtocol {
    var input: SplashViewModelInputProtocol { get }
    var output: SplashViewModelOutputProtocol { get }
}

protocol SplashViewModelInputProtocol {
    func presentNextViewController(withUser user: User?, presenter: TransitionHandler)
}

protocol SplashViewModelOutputProtocol {
    var authState: PublishRelay<User?> { get }
}

final class SplashViewModel {

    // MARK: Public properties
    var input: SplashViewModelInputProtocol { return self }
    var output: SplashViewModelOutputProtocol { return self }

    var authState = PublishRelay<User?>()

    // MARK: Private properties
    private let coordinator: CoordinatorProtocol
    private let authManager: AuthManagerSplashProtocol
    private let disposeBag = DisposeBag()

    // MARK: Init
    init(coordinator: CoordinatorProtocol,
         authManager: AuthManagerSplashProtocol) {
        self.authManager = authManager
        self.coordinator = coordinator

        authManager.checkIsUserAlreadyLoginedIn()
            .subscribe { [authState] result in

                switch result {
                case .success((let isLoginedIn, let user)):
                    if isLoginedIn, let user = user {
                        authState.accept(user)
                        break
                    } else if !isLoginedIn {
                        authState.accept(nil)
                    }
                case .failure: break
                }
            }
            .disposed(by: disposeBag)

    }
}

// MARK: - extension + SplashViewModelProtocol -
extension SplashViewModel: SplashViewModelProtocol {
}

// MARK: - extension + SplashViewModelInputProtocol -
extension SplashViewModel: SplashViewModelInputProtocol {
    func presentNextViewController(withUser user: User?, presenter: TransitionHandler) {
        if let user = user {
            coordinator.presentTabBarViewController(withUser: user, showSplash: false)
        } else {
            coordinator.presentRegisterViewController()
        }
    }
}

// MARK: - extension + SplashViewModelOutputProtocol -
extension SplashViewModel: SplashViewModelOutputProtocol {
}
