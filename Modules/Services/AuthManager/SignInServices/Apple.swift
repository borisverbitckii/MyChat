//
//  AppleAuth.swift
//  Services
//
//  Created by Boris Verbitsky on 08.05.2022.
//

import Models
import Logger
import Foundation
import AuthenticationServices

final class AppleAuth: NSObject {

    private var signInClosure: ((String) -> Void)?
    private var obs: ((Result<ChatUser?, Error>) -> Void)?
    private var hideActivityIndicator: (() -> Void)?

    func setupSignInClosure(closure: @escaping (String) -> Void) {
        self.signInClosure = closure
    }

    func setupObs(with obs: @escaping (Result<ChatUser?, Error>) -> Void) {
        self.obs = obs
    }
}

extension AppleAuth: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        obs?(.failure(error))
    }

    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredentials = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let appleIDToken = appleIDCredentials.identityToken else {
                Logger.log(to: .error, message: "Не удалось получить appleIDToken")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                Logger.log(to: .error, message: "Не удалось перевести appleIDToken в string")
                return
            }
            signInClosure?(idTokenString)
        }

    }
}

extension AppleAuth: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let appDelegate = UIApplication.shared.delegate,
              let window = appDelegate.window,
              let window = window else { return UIWindow() }
        return window
    }
}
