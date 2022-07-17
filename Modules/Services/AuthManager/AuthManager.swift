//
//  AuthManager.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Models
import Logger
import RxSwift
import Firebase
import CoreData
import Analytics
import GoogleSignIn
import FBSDKLoginKit
import AuthenticationServices

public protocol AuthManagerSplashProtocol {         // для SplashViewController
    func checkIsUserAlreadyLoggedIn() -> Single<ChatUser?>
}

public protocol AuthManagerRegisterProtocol {       // для RegisterViewController
    func createUser(withEmail email: String, password: String) -> Single<ChatUser?>
    func signIn(withEmail email: String,
                password: String) -> Single<ChatUser?>
    func signInWithFacebook(presenterVC: UIViewController,
                            showActivityIndicator: @escaping () -> Void) -> Single<ChatUser?>
    func signInWithGoogle(presenterVC: UIViewController,
                          showActivityIndicator: @escaping () -> Void) -> Single<ChatUser?>
    func signInWithApple(showActivityIndicator: @escaping () -> Void) -> Single<ChatUser?>
    func signOut() -> Single<Any?>
}

public protocol AuthManagerSettingsProtocol {         // для SettingsViewController
    func signOut() -> Single<Any?>
}

public final class AuthManager {

    public static var currentUser: User? {
        Auth.auth().currentUser
    }

    // MARK: Public properties
    private let encryptHandler: EncryptHandlerProtocol
    private lazy var auth = Auth.auth()
    private lazy var appleAuth = AppleAuth()
    private lazy var bag = DisposeBag()

    // MARK: Init
    public init(encryptHandler: EncryptHandlerProtocol = EncryptHandler()) {
        self.encryptHandler = encryptHandler
    }
}

// MARK: - extension + AuthManagerSplashProtocol -
extension AuthManager: AuthManagerSplashProtocol {

    public func checkIsUserAlreadyLoggedIn() -> Single<ChatUser?> {
        Single<ChatUser?>.create { [auth] observer in
            auth.addStateDidChangeListener { _, user in
                if let user = user {
                    let chatUser = ChatUser(id: user.uid,
                                            name: user.displayName ?? "",
                                            email: user.email ?? "",
                                            avatarURL: user.photoURL?.absoluteString)

                    AnalyticReporter.logEvent(.login(loginMethod: "firebase"))
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

    public func createUser(withEmail email: String,
                           password: String) -> Single<ChatUser?> {
        Single<ChatUser?>.create { [auth] observer in
            auth.createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    Logger.log(to: .error,
                               message: "Не удалось зарегистрировать пользователя в firebase с e-mail и паролем",
                               error: error)
                    observer(.failure(error))
                }

                if let uid = authResult?.user.uid {
                    let chatUser = ChatUser(id: uid,
                                            name: authResult?.user.displayName ?? "",
                                            email: authResult?.user.email ?? "",
                                            avatarURL: authResult?.user.photoURL?.absoluteString)
                    AnalyticReporter.logEvent(.signup(signupMethod: "email"))
                    Logger.log(to: .info,
                               message: "Зарегистрировался новый пользователь, uid: \(uid)")
                    observer(.success(chatUser))
                }

                auth.currentUser?.sendEmailVerification(completion: { error in
                    if let error = error {
                        Logger.log(to: .error,
                                   message: "Не удалось отправить e-mail для подтверждения регистрации в firebase",
                                   error: error)
                    }
                })

            }
            return Disposables.create()
        }
    }

    public func signIn(withEmail email: String,
                       password: String) -> Single<ChatUser?> {
        Single<ChatUser?>.create { [auth] observer in
            auth.signIn(withEmail: email,
                        password: password) { authResult, error in
                if let error = error {
                    Logger.log(to: .error,
                               message: "Не удалось авторизироваться в firebase через e-mail и пароль",
                               error: error)
                    observer(.failure(error))
                    return
                }

                if let uid = authResult?.user.uid {
                    let chatUser = ChatUser(id: uid,
                                            name: authResult?.user.displayName ?? "",
                                            email: authResult?.user.email ?? "",
                                            avatarURL: authResult?.user.photoURL?.absoluteString)
                    AnalyticReporter.logEvent(.login(loginMethod: "email"))
                    Logger.log(to: .info,
                               message: "Пользователь авторизировался с логином и паролем, uid: \(uid)")
                    observer(.success(chatUser))
                }
            }
            return Disposables.create()
        }
    }

    public func signInWithFacebook(presenterVC: UIViewController,
                                   showActivityIndicator: @escaping () -> Void) -> Single<ChatUser?> {
        return Single<ChatUser?>.create { [weak self] observer in
            let fbLoginManager = LoginManager()
            fbLoginManager.logIn(permissions: [], from: presenterVC) { result, error in
                if let error = error {
                    Logger.log(to: .error,
                               message: "Не удалось авторизироваться в facebook",
                               error: error)
                    observer(.failure(error))
                    return
                }

                if let result = result {
                    if result.isCancelled {
                        Logger.log(to: .notice,
                                   message: "Пользователь прервал авторизацию через facebook")
                        observer(.failure(NSError()))
                        return
                    }

                    showActivityIndicator()
                    AnalyticReporter.logEvent(.login(loginMethod: "facebook"))
                    Logger.log(to: .notice,
                               message: "Пользователь авторизировался через facebook")

                    let credential = FacebookAuthProvider
                        .credential(withAccessToken: AccessToken.current!.tokenString)

                    self?.signInToFirebase(credentials: credential,
                                           observer: observer)
                }
            }
            return Disposables.create()
        }
    }

    public func signInWithGoogle(presenterVC: UIViewController,
                                 showActivityIndicator: @escaping () -> Void) -> Single<ChatUser?> {
        Single<ChatUser?>.create { [weak self] observer in
            if let clientID = FirebaseApp.app()?.options.clientID {
                let config = GIDConfiguration(clientID: clientID)
                GIDSignIn.sharedInstance.signIn(with: config,
                                                presenting: presenterVC) { user, error in
                    if let error = error {
                        Logger.log(to: .error,
                                   message: "Не удалось авторизироваться в google",
                                   error: error)
                        observer(.failure(error))
                        return
                    }

                    showActivityIndicator()

                    guard let authentication = user?.authentication,
                          let idToken = authentication.idToken else { return }

                    let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                                   accessToken: authentication.accessToken)
                    AnalyticReporter.logEvent(.login(loginMethod: "google"))
                    Logger.log(to: .notice,
                               message: "Пользователь авторизировался через google")

                    self?.signInToFirebase(credentials: credential,
                                           observer: observer)
                }
            }
            return Disposables.create()
        }
    }

    public func signInWithApple(showActivityIndicator: @escaping () -> Void) -> Single<ChatUser?> {
        Single<ChatUser?>.create { [appleAuth, encryptHandler, bag] obs in
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.email, .fullName]
            let currentNonce =  encryptHandler.randomNonceString(length: 32)
            request.nonce = encryptHandler.sha256(currentNonce)

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.presentationContextProvider = appleAuth
            authorizationController.delegate = appleAuth

            appleAuth.setupObs(with: obs)

            appleAuth.setupSignInClosure { [weak self] token in
                self?.sighInWithAppleInFirebase(idTokenForAuth: token,
                                                nonce: currentNonce)
                .subscribe { chatUser in
                    obs(.success(chatUser))
                } onFailure: { error in
                    obs(.failure(error))
                }
                .disposed(by: bag)
            }

            showActivityIndicator()
            authorizationController.performRequests()

            return Disposables.create()
        }
    }

    // MARK: Private methods
    private func sighInWithAppleInFirebase(idTokenForAuth: String,
                                           nonce: String) -> Single<ChatUser?> {
        Single<ChatUser?>.create { [weak self] observer in
            let credential: AuthCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                                      idToken: idTokenForAuth,
                                                                      rawNonce: nonce)
            AnalyticReporter.logEvent(.login(loginMethod: "apple"))
            Logger.log(to: .notice,
                       message: "Пользователь авторизировался через apple")

            self?.signInToFirebase(credentials: credential,
                                   observer: observer)
            return Disposables.create()
        }
    }

    private func signInToFirebase(credentials: AuthCredential,
                                  observer: @escaping (Result<ChatUser?, Error>) -> Void) {
        Auth.auth().signIn(with: credentials) { authResult, error in
            if let error = error {
                Logger.log(to: .error,
                           message: "Не удалось авторизироваться в firebase",
                           error: error)
                observer(.failure(error))
                return
            }
            if let uid = authResult?.user.uid {
                let chatUser = ChatUser(id: uid,
                                        name: authResult?.user.displayName ?? "",
                                        email: authResult?.user.email ?? "",
                                        avatarURL: authResult?.user.photoURL?.absoluteString)
                Logger.log(to: .notice,
                           message: "Пользователь авторизировался через firebase",
                           userInfo: ["uid": uid])
                observer(.success(chatUser))
            }
        }
    }
}

// MARK: - extension + AuthManagerProfileProtocol -
extension AuthManager: AuthManagerSettingsProtocol {
    public func signOut() -> Single<Any?> {
        Single<Any?>.create { [auth] observer in
            do {
                try auth.signOut()
                AnalyticReporter.logEvent(.signOut)
                observer(.success(nil))
            } catch let signOutError as NSError {
                observer(.failure(signOutError))
            }
            return Disposables.create()
        }
    }
}
