//
//  SplashViewModel.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit
import Models
import Logger
import RxRelay
import RxSwift
import Services

protocol SplashViewModelProtocol {
    var input: SplashViewModelInputProtocol { get }
    var output: SplashViewModelOutputProtocol { get }
}

protocol SplashViewModelInputProtocol {
    func viewDidLoad(presenter: TransitionHandler)
}

protocol SplashViewModelOutputProtocol {
}

final class SplashViewModel {

    // MARK: Public properties
    var input: SplashViewModelInputProtocol { return self }
    var output: SplashViewModelOutputProtocol { return self }

    // MARK: Private properties
    private let coordinator: CoordinatorProtocol
    private let authManager: AuthManagerSplashProtocol
    private let disposeBag = DisposeBag()

    // MARK: Init
    init(coordinator: CoordinatorProtocol,
         authManager: AuthManagerSplashProtocol) {
        self.authManager = authManager
        self.coordinator = coordinator
    }
}

// MARK: - extension + SplashViewModelProtocol -
extension SplashViewModel: SplashViewModelProtocol {
}

// MARK: - extension + SplashViewModelInputProtocol -
extension SplashViewModel: SplashViewModelInputProtocol {

    func viewDidLoad(presenter: TransitionHandler) {
        authManager.checkIsUserAlreadyLoggedIn()
            .subscribe { [weak self] result in
                switch result {
                case .success(let user):
                    if let user = user {
                        self?.coordinator.presentTabBarViewController(withChatUser: user)
                        Logger.log(to: .info, message: "Пользователь уже авторизован", userInfo: ["uid": user.uid])
                    } else {
                        self?.coordinator.presentRegisterViewController(presenter: presenter)
                        Logger.log(to: .notice, message: "Пользователь не авторизован")
                    }
                default: break
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - extension + SplashViewModelOutputProtocol -
extension SplashViewModel: SplashViewModelOutputProtocol {
}
