//
//  SplashViewModel.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit
import RxRelay
import RxSwift
import Services
import Models

protocol SplashViewModelProtocol {
    var input: SplashViewModelInputProtocol { get }
    var output: SplashViewModelOutputProtocol { get }
}

protocol SplashViewModelInputProtocol {
    func presentNextViewController(withChatUser user: ChatUser?, presenter: TransitionHandler)
}

protocol SplashViewModelOutputProtocol {
    var authState: PublishRelay<ChatUser?> { get }
}

final class SplashViewModel {

    // MARK: Public properties
    var input: SplashViewModelInputProtocol { return self }
    var output: SplashViewModelOutputProtocol { return self }

    var authState = PublishRelay<ChatUser?>()

    // MARK: Private properties
    private let coordinator: CoordinatorProtocol
    private let authManager: AuthManagerSplashProtocol
    private let disposeBag = DisposeBag()

    // MARK: Init
    init(coordinator: CoordinatorProtocol,
         authManager: AuthManagerSplashProtocol) {
        self.authManager = authManager
        self.coordinator = coordinator

        authManager.checkIsUserAlreadyLoggedInIn()
            .subscribe { [authState] result in

                switch result {
                case .success(let chatUser):
                    authState.accept(chatUser)
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
    func presentNextViewController(withChatUser user: ChatUser?, presenter: TransitionHandler) {
        if let user = user {
            coordinator.presentTabBarViewController(withChatUser: user)
        } else {
            coordinator.presentRegisterViewController(presenter: presenter)
        }
    }
}

// MARK: - extension + SplashViewModelOutputProtocol -
extension SplashViewModel: SplashViewModelOutputProtocol {
}
