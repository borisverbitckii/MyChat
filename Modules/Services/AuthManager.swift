//
//  AuthManager.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Models
import RxSwift
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import AuthenticationServices

public protocol AuthManagerSplashProtocol {         // для SplashViewController
    func checkIsUserAlreadyLoggedInIn() -> Single<ChatUser?>
}

public protocol AuthManagerRegisterProtocol {       // для RegisterViewController
    func createUser(withEmail email: String, password: String) -> Single<ChatUser?>
    func signIn(withEmail email: String,
                password: String) -> Single<ChatUser?>
    func signInWithFacebook(presenterVC: UIViewController) -> Single<ChatUser?>
    func signInWithGoogle(presenterVC: UIViewController) -> Single<ChatUser?>
    func signInWithApple(delegate:  ASAuthorizationControllerDelegate?,
                         provider: ASAuthorizationControllerPresentationContextProviding?)
    -> ((String) -> (Single<ChatUser?>))
    func signOut() -> Single<Any?>
}

public protocol AuthManagerProfileProtocol {         // для ProfileViewController
    func signOut() -> Single<Any?>
}

public final class AuthManager {

    // MARK: Public properties
    private let auth = Auth.auth()
    private let encryptHandler: EncryptHandlerProtocol

    // MARK: Init
    public init(encryptHandler: EncryptHandlerProtocol = EncryptHandler()) {
        self.encryptHandler = encryptHandler
    }
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

    public func signInWithFacebook(presenterVC: UIViewController) -> Single<ChatUser?> {
        return Single<ChatUser?>.create { [weak self] observer in
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

                    self?.signInToFirebase(credentials: credential, observer: observer)
                }
            }
            return Disposables.create()
        }
    }

    public func signInWithGoogle(presenterVC: UIViewController) -> Single<ChatUser?> {
        Single<ChatUser?>.create { [weak self] observer in
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
                    self?.signInToFirebase(credentials: credential, observer: observer)
                }
            }
            return Disposables.create()
        }
    }

    public func signInWithApple(delegate:  ASAuthorizationControllerDelegate?,
                                provider: ASAuthorizationControllerPresentationContextProviding?) ->
    (String) -> (Single<ChatUser?>){
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email, .fullName]
        let currentNonce =  encryptHandler.randomNonceString(length: 32)
        request.nonce = encryptHandler.sha256(currentNonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = delegate
        authorizationController.presentationContextProvider = provider
        authorizationController.performRequests()
        return { [sighInWithAppleInFirebase] idTokenString in
            sighInWithAppleInFirebase(idTokenString, currentNonce)
        }
    }

    // MARK: Private methods
    private func sighInWithAppleInFirebase(idTokenForAuth: String, nonce: String) -> Single<ChatUser?> {
        Single<ChatUser?>.create { [weak self] observer in

            let credential: AuthCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                                      idToken: idTokenForAuth,
                                                                      rawNonce: nonce)
            self?.signInToFirebase(credentials: credential, observer: observer)
            return Disposables.create()
        }
    }

    private func signInToFirebase(credentials: AuthCredential,
                                  observer: @escaping (Result<ChatUser?, Error>) -> Void ) {
        Auth.auth().signIn(with: credentials) { authResult, error in
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
