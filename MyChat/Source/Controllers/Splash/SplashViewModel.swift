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
}

protocol SplashViewModelInputProtocol {
    func checkAuth(coordinator: CoordinatorProtocol)
}

final class SplashViewModel {

    // MARK: Public properties
    var input: SplashViewModelInputProtocol { return self }

    // MARK: Private properties
    private let authManager: AuthManagerSplashProtocol
    private let remoteDataBaseManager: RemoteDataBaseManagerProtocol
    private lazy var disposeBag = DisposeBag()

    // MARK: Init
    init(authManager: AuthManagerSplashProtocol,
         remoteDataBaseManager: RemoteDataBaseManagerProtocol) {
        self.authManager = authManager
        self.remoteDataBaseManager = remoteDataBaseManager
    }
}

// MARK: - extension + SplashViewModelProtocol -
extension SplashViewModel: SplashViewModelProtocol {
}

// MARK: - extension + SplashViewModelInputProtocol -
extension SplashViewModel: SplashViewModelInputProtocol {

    func checkAuth(coordinator: CoordinatorProtocol) {
        authManager.checkIsUserAlreadyLoggedIn()
            .subscribe { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let user):
                    if let user = user {
                        Logger.log(to: .info, message: "Пользователь уже авторизован", userInfo: ["uid": user.id])
                        /// Подгрузка данных о пользователе из удаленной БД
                        self.remoteDataBaseManager.fetchUser(fetchType: .selfUser, id: user.id)
                            .subscribe { result in
                                switch result {
                                case .success(let chatUser):
                                    guard let chatUser = chatUser else { return }
                                    coordinator.presentChatsListNavigationController(withChatUser: chatUser)
                                case .failure: break
                                }
                            }
                            .disposed(by: self.disposeBag)
                    } else {
                        coordinator.presentRegisterViewController()
                        Logger.log(to: .notice, message: "Пользователь не авторизован")
                    }
                default: break
                }
            }
            .disposed(by: disposeBag)
    }
}
