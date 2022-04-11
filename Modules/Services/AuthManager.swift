//
//  AuthManager.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import RxSwift
import Firebase
import GoogleSignIn
import FBSDKLoginKit

public protocol AuthManagerSplashProtocol { // для SplashViewController
    func checkIsUserAlreadyLoginedIn() -> Single<(isLoginedIn: Bool, user: User?)>
}

public protocol AuthManagerRegisterProtocol {       // для RegisterViewController
    func createUser(withEmail email: String, password: String) -> Single<AuthDataResult?>
    func signIn(withEmail email: String,
                password: String) -> Single<AuthDataResult?>
    func signInWithFacebook(presenterVC: UIViewController) -> Single<AuthDataResult?>
    func signInWithGoogle(presenterVC: UIViewController) -> Single<AuthDataResult?>
    func signOut() -> Single<Any?>
}

public protocol AuthManagerProfileProtocol {
    func signOut() -> Single<Any?>
}

public final class AuthManager {

    // MARK: Public properties
    private let auth = Auth.auth()

    // MARK: Init
    public init() {}
}

// MARK: - extension + AuthManagerSplashProtocol -
extension AuthManager: AuthManagerSplashProtocol {

    public func checkIsUserAlreadyLoginedIn() -> Single<(isLoginedIn: Bool, user: User?)> {
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

    public func createUser(withEmail email: String, password: String) -> Single<AuthDataResult?> {
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

    public func signIn(withEmail email: String,
                       password: String) -> Single<AuthDataResult?> {
        Single<AuthDataResult?>.create { [auth] observer in
            auth.signIn(withEmail: email,
                        password: password) { authResult, error in
                if let error = error {
                    observer(.failure(error))
                    return
                }
                observer(.success(authResult))
            }
            return Disposables.create()
        }
    }

    public func signInWithFacebook(presenterVC: UIViewController) -> Single<AuthDataResult?> {
        return Single<AuthDataResult?>.create { observer in
            let fbLoginManager = LoginManager()
            fbLoginManager.logIn(permissions: [], from: presenterVC) { result, error in
                if let error = error {
                    observer(.failure(error))
                    return
                }

                if let result = result {
                    if result.isCancelled {
                        return
                    }

                    let credential = FacebookAuthProvider
                        .credential(withAccessToken: AccessToken.current!.tokenString)

                    Auth.auth().signIn(with: credential) { authResult, error in
                        if let error = error {
                            observer(.failure(error))
                            return
                        }

                        if let authResult = authResult {
                            observer(.success(authResult))
                        }
                    }
                }
            }
            return Disposables.create()
        }
    }

    public func signInWithGoogle(presenterVC: UIViewController) -> Single<AuthDataResult?> {
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
    public func signOut() -> Single<Any?> {
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
