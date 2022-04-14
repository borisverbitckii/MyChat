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
import Models

public protocol AuthManagerSplashProtocol {         // для SplashViewController
    func checkIsUserAlreadyLoggedInIn() -> Single<ChatUser?>
}

public protocol AuthManagerRegisterProtocol {       // для RegisterViewController
    func createUser(withEmail email: String, password: String) -> Single<ChatUser?>
    func signIn(withEmail email: String,
                password: String) -> Single<ChatUser?>
    func sighInWithApple(idTokenForAuth: String, nonce: String) -> Single<ChatUser?>
    func signInWithFacebook(presenterVC: UIViewController) -> Single<ChatUser?>
    func signInWithGoogle(presenterVC: UIViewController) -> Single<ChatUser?>
    func signOut() -> Single<Any?>
}

public protocol AuthManagerProfileProtocol {         // для ProfileViewController
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

    public func checkIsUserAlreadyLoggedInIn() -> Single<ChatUser?> {
        Single<ChatUser?>.create { [auth] observer in
            auth.addStateDidChangeListener { _, user in
                if let user = user {
                    let chatUser = ChatUser(uid: user.uid,
                                            email: user.email,
                                            name: user.displayName,
                                            surname: nil,
                                            avatarURL: user.photoURL)
                    observer(.success(chatUser))
                } else {
                    observer(.success(nil))
                }
            }
            return Disposables.create()
        }
    }
}

// MARK: - extension + AuthManagerProtocol -
extension AuthManager: AuthManagerRegisterProtocol {

    public func createUser(withEmail email: String, password: String) -> Single<ChatUser?> {
        Single<ChatUser?>.create { [auth] observer in
            auth.createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    observer(.failure(error))
                }

                if let uid = authResult?.user.uid {
                    let chatUser = ChatUser(uid: uid,
                                            email: authResult?.user.email,
                                            isEmailVerified: authResult?.user.isEmailVerified,
                                            name: authResult?.user.displayName,
                                            surname: nil,
                                            avatarURL: authResult?.user.photoURL)
                    
                    observer(.success(chatUser))
                }


                auth.currentUser?.sendEmailVerification(completion: { error in
                    if let error = error {
                        observer(.failure(error))
                    }
                })

            }
            return Disposables.create()
        }
        .subscribe(on: SerialDispatchQueueScheduler(internalSerialQueueName: "authQueue"))
        .observe(on: MainScheduler.instance)
    }

    public func signIn(withEmail email: String,
                       password: String) -> Single<ChatUser?> {
        Single<ChatUser?>.create { [auth] observer in
            auth.signIn(withEmail: email,
                        password: password) { authResult, error in
                if let error = error {
                    observer(.failure(error))
                    return
                }

                if let uid = authResult?.user.uid {
                    let chatUser = ChatUser(uid: uid,
                                            email: authResult?.user.email,
                                            isEmailVerified: authResult?.user.isEmailVerified,
                                            name: authResult?.user.displayName,
                                            surname: nil,
                                            avatarURL: authResult?.user.photoURL)

                    observer(.success(chatUser))
                }
            }
            return Disposables.create()
        }
    }

    public func sighInWithApple(idTokenForAuth: String, nonce: String) -> Single<ChatUser?> {
        Single<ChatUser?>.create { observer in

            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenForAuth,
                                                      rawNonce: nonce)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    observer(.failure(error))
                    return
                }

                if let uid = authResult?.user.uid {
                    let chatUser = ChatUser(uid: uid,
                                            email: authResult?.user.email,
                                            isEmailVerified: authResult?.user.isEmailVerified,
                                            name: authResult?.user.displayName,
                                            surname: nil,
                                            avatarURL: authResult?.user.photoURL)

                    observer(.success(chatUser))
                }
            }

            return Disposables.create()
        }
    }

    public func signInWithFacebook(presenterVC: UIViewController) -> Single<ChatUser?> {
        return Single<ChatUser?>.create { observer in
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

                        if let uid = authResult?.user.uid {
                            let chatUser = ChatUser(uid: uid,
                                                    email: authResult?.user.email,
                                                    isEmailVerified: authResult?.user.isEmailVerified,
                                                    name: authResult?.user.displayName,
                                                    surname: nil,
                                                    avatarURL: authResult?.user.photoURL)

                            observer(.success(chatUser))
                        }
                    }
                }
            }
            return Disposables.create()
        }
    }

    public func signInWithGoogle(presenterVC: UIViewController) -> Single<ChatUser?> {
        Single<ChatUser?>.create { observer in
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
                        if let uid = authResult?.user.uid {
                            let chatUser = ChatUser(uid: uid,
                                                    email: authResult?.user.email,
                                                    isEmailVerified: authResult?.user.isEmailVerified,
                                                    name: authResult?.user.displayName,
                                                    surname: nil,
                                                    avatarURL: authResult?.user.photoURL)

                            observer(.success(chatUser))
                        }
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
