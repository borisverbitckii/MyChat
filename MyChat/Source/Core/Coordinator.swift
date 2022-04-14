//
//  Coordinator.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit
import Services
import Models

protocol CoordinatorProtocol: AnyObject {
    func injectModuleFactory(moduleFactory: ModuleFactory)

    func presentTabBarViewController(withChatUser user: ChatUser)
    func presentSplashViewController(presenter: TransitionHandler)
    func presentRegisterViewController(presenter: TransitionHandler)
}

final class Coordinator {

    // MARK: Private properties
    private var window: UIWindow
    private var moduleFactory: ModuleFactory?

    // MARK: Init
    init(window: UIWindow) {
        self.window = window
    }
}

// MARK: - Coordinator + CoordinatorProtocol -
extension Coordinator: CoordinatorProtocol {

    func injectModuleFactory(moduleFactory: ModuleFactory) {
        self.moduleFactory = moduleFactory
    }

    func presentTabBarViewController(withChatUser user: ChatUser) {
        window.rootViewController = moduleFactory?.getTabBarController()
        window.makeKeyAndVisible()

        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil)
    }

    func presentRegisterViewController(presenter: TransitionHandler) {
        guard let registerViewController = self.moduleFactory?.getRegisterViewController() else { return }
        window.rootViewController = registerViewController
        window.makeKeyAndVisible()

        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil)
    }

    /// Презентация SplashViewController
    /// - Parameter presenter: Презентующий контроллер
    ///
    /// Модуль сплеша для проверки авторизации
    func presentSplashViewController(presenter: TransitionHandler) {
        guard let transitionViewController = moduleFactory?.getSplashModule(coordinator: self) else { return }
        transitionViewController.modalPresentationStyle = .fullScreen
        presenter.presentViewController(viewController: transitionViewController,
                                        animated: false,
                                        completion: nil)
    }
}
