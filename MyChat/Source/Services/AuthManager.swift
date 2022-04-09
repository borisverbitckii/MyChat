//
//  AuthManager.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Firebase
import RxSwift
import GoogleSignIn

protocol AuthManagerSplashProtocol { // для SplashViewController
    func checkIsUserAlreadyLoginedIn() -> Single<(isLoginedIn: Bool, user: User?)>
}

protocol AuthManagerRegisterProtocol {       // для RegisterViewController
    func createUser(withEmail email: String, password: String) -> Single<AuthDataResult?>
    func signIn(withEmail email: String,
                password: String) -> Single<AuthDataResult?>
    func sighInWithGoogle(presenterVC: UIViewController) -> Single<AuthDataResult?>
    func signOut() -> Single<Any?>
}

protocol AuthManagerProfileProtocol {
    func signOut() -> Single<Any?>
}

final class AuthManager {

    // MARK: Public properties
    private let auth = Auth.auth()
}

// MARK: - extension + AuthManagerSplashProtocol -
extension AuthManager: AuthManagerSplashProtocol {

    func checkIsUserAlreadyLoginedIn() -> Single<(isLoginedIn: Bool, user: User?)> {
        Single<(isLoginedIn: Bool, user: User?)>.create { [auth] observer in
            auth.addStateDidChangeListener { _, user in
                if let user = user {
                    observer(.success((isLoginedIn: true, user: user)))
                } else {
                    observer(.success((isLoginedIn: false, user: user)))
                }
            }
            return Disposables.create()
        }
    }
}

// MARK: - extension + AuthManagerProtocol -
extension AuthManager: AuthManagerRegisterProtocol {

    func createUser(withEmail email: String, password: String) -> Single<AuthDataResult?> {
        Single<AuthDataResult?>.create { [auth] observer in

            auth.createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    observer(.failure(error))
                }
                observer(.success(authResult))
            }
            return Disposables.create()
        }
        .subscribe(on: SerialDispatchQueueScheduler(internalSerialQueueName: "authQueue"))
        .observe(on: MainScheduler.instance)
    }

    func signIn(withEmail email: String,
                password: String) -> Single<AuthDataResult?> {
        Single<AuthDataResult?>.create { [auth] observer in
            auth.signIn(withEmail: email,
                               password: password) { authResult, error in
                if let error = error {
                    observer(.failure(error))
                }
                observer(.success(authResult))
            }
            return Disposables.create()
        }
    }

    func sighInWithGoogle(presenterVC: UIViewController) -> Single<AuthDataResult?> {
        Single<AuthDataResult?>.create { observer in
            if let clientID = FirebaseApp.app()?.options.clientID {
                let config = GIDConfiguration(clientID: clientID)
                GIDSignIn.sharedInstance.signIn(with: config,
                                                presenting: presenterVC) { user, error in
                    if let error = error {
                        observer(.failure(error))
                        return
                    }
                    guard let authentication = user?.authentication,
                          let idToken = authentication.idToken else { return }

                    let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                                   accessToken: authentication.accessToken)
                    Auth.auth().signIn(with: credential) { authResult, error in
                        if let error = error {
                            observer(.failure(error))
                            return
                        }
                        observer(.success(authResult))
                    }
                }
            }
            return Disposables.create()
        }
    }
}

// MARK: - extension + AuthManagerProfileProtocol -
extension AuthManager: AuthManagerProfileProtocol {
    func signOut() -> Single<Any?> {
        Single<Any?>.create { [auth] observer in
            do {
                try auth.signOut()
                observer(.success(nil))
            } catch let signOutError as NSError {
                observer(.failure(signOutError))
            }
            return Disposables.create()
        }
    }
}
