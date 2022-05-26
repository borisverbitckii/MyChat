//
//  AuthFacade.swift
//  MyChat
//
//  Created by Boris Verbitsky on 07.05.2022.
//

import Models
import RxSwift
import Services
import AuthenticationServices

protocol AuthFacadeProtocol {
    func createUser(withEmail email: String,
                    password: String,
                    hideActivityIndicator: @escaping () -> Void) -> Single<ChatUser?>
    func signIn(withEmail email: String,
                password: String,
                hideActivityIndicator: @escaping () -> Void) -> Single<ChatUser?>
    func signInWithFacebook(presenterVC: UIViewController,
                            showActivityIndicator: @escaping () -> Void,
                            hideActivityIndicator: @escaping () -> Void) -> Single<ChatUser?>
    func signInWithGoogle(presenterVC: UIViewController,
                          showActivityIndicator: @escaping () -> Void,
                          hideActivityIndicator: @escaping () -> Void) -> Single<ChatUser?>
    func signInWithApple(showActivityIndicator: @escaping () -> Void,
                         hideActivityIndicator: @escaping () -> Void) -> Single<ChatUser?>
}

final class AuthFacade {

    // MARK: Private properties
    private let authManager: AuthManagerRegisterProtocol
    private let remoteDatabaseManager: RemoteDataBaseManagerProtocol
    private lazy var bag = DisposeBag()

    // MARK: Init
    init(authManager: AuthManagerRegisterProtocol,
         remoteDatabaseManager: RemoteDataBaseManagerProtocol) {
        self.authManager = authManager
        self.remoteDatabaseManager = remoteDatabaseManager
    }

}

// MARK: - extension + AuthFacadeProtocol -
extension AuthFacade: AuthFacadeProtocol {

    func createUser(withEmail email: String,
                    password: String,
                    hideActivityIndicator: @escaping () -> Void) -> Single<ChatUser?> {
        Single<ChatUser?>.create { [weak self, bag] obs in
            self?.authManager.createUser(withEmail: email,
                                         password: password)
            .subscribe { user in
                self?.saveUserToDatabase(user: user,
                                         obs: obs,
                                         hideActivityIndicator: hideActivityIndicator)
            } onFailure: { error in
                hideActivityIndicator()
                obs(.failure(error))
            }
            .disposed(by: bag)
            return Disposables.create()
        }
    }

    func signIn(withEmail email: String,
                password: String,
                hideActivityIndicator: @escaping () -> Void) -> Single<ChatUser?> {
        Single<ChatUser?>.create { [weak self, bag] obs in
            self?.authManager.signIn(withEmail: email,
                                     password: password)
            .subscribe { user in
                self?.saveUserToDatabase(user: user,
                                         obs: obs,
                                         hideActivityIndicator: hideActivityIndicator)
            } onFailure: { error in
                hideActivityIndicator()
                obs(.failure(error))
            }
            .disposed(by: bag)

            return Disposables.create()
        }
    }

    func signInWithFacebook(presenterVC: UIViewController,
                            showActivityIndicator: @escaping () -> Void,
                            hideActivityIndicator: @escaping () -> Void) -> Single<ChatUser?> {
        Single<ChatUser?>.create { [weak self, bag] obs in
            self?.authManager.signInWithFacebook(presenterVC: presenterVC,
                                                 showActivityIndicator: showActivityIndicator)
            .subscribe { user in
                self?.saveUserToDatabase(user: user,
                                         obs: obs,
                                         hideActivityIndicator: hideActivityIndicator)
            } onFailure: { error in
                hideActivityIndicator()
                obs(.failure(error))
            }
            .disposed(by: bag)
            return Disposables.create()
        }
    }

    func signInWithGoogle(presenterVC: UIViewController,
                          showActivityIndicator: @escaping () -> Void,
                          hideActivityIndicator: @escaping () -> Void) -> Single<ChatUser?> {
        Single<ChatUser?>.create { [weak self, bag] obs in
            self?.authManager.signInWithGoogle(presenterVC: presenterVC,
                                               showActivityIndicator: showActivityIndicator)
            .subscribe { user in
                self?.saveUserToDatabase(user: user,
                                         obs: obs,
                                         hideActivityIndicator: hideActivityIndicator)
            } onFailure: { error in
                hideActivityIndicator()
                obs(.failure(error))
            }
            .disposed(by: bag)
            return Disposables.create()
        }
    }

    func signInWithApple(showActivityIndicator: @escaping () -> Void,
                         hideActivityIndicator: @escaping () -> Void) -> Single<ChatUser?> {
        Single<ChatUser?>.create { [weak self, bag] obs in
            self?.authManager.signInWithApple(showActivityIndicator: showActivityIndicator)
            .subscribe { user in
                self?.saveUserToDatabase(user: user, obs: obs,
                                         hideActivityIndicator: hideActivityIndicator)
            } onFailure: { error in
                hideActivityIndicator()
                obs(.failure(error))
            }
            .disposed(by: bag)
            return Disposables.create()
        }
    }

    func signOut() -> Single<Any?> {
        authManager.signOut()
    }

    // MARK: Private methods
    private func saveUserToDatabase(user: ChatUser?,
                                    obs: @escaping (Result<ChatUser?, Error>) -> Void,
                                    hideActivityIndicator: @escaping () -> Void) {
        guard let user = user else { return }

        remoteDatabaseManager.saveUserData(with: user)
            .subscribe { _ in
                obs(.success(user))
                hideActivityIndicator()
            } onFailure: { error in
                obs(.failure(error))
                hideActivityIndicator()
            }
            .disposed(by: bag)
    }
}
