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
    func injectModuleFactory(moduleFactory: ModuleFactoryProtocol)

    func presentSplashViewController()
    func presentTabBarViewController(withChatUser user: ChatUser)
    func presentRegisterViewController(presenter: TransitionHandler)
}

final class Coordinator {

    // MARK: Private properties
    private var window: UIWindow
    private var moduleFactory: ModuleFactoryProtocol?

    /// Заглушка, чтобы не было мерцаний при переходе на splashViewController, пока грузится config
    private lazy var emptyViewController: UIViewController = {
        $0.view.backgroundColor = .white /// Цвет фона должен быть такой же, как у splashViewController
        return $0
    }(UIViewController())

    // MARK: Init
    init(window: UIWindow) {
        self.window = window
        window.rootViewController = emptyViewController
        window.makeKeyAndVisible()
    }
}

// MARK: - Coordinator + CoordinatorProtocol -
extension Coordinator: CoordinatorProtocol {

    func injectModuleFactory(moduleFactory: ModuleFactoryProtocol) {
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
    func presentSplashViewController() {
        guard let transitionViewController = moduleFactory?.getSplashModule(coordinator: self) else { return }
        transitionViewController.modalPresentationStyle = .fullScreen
        emptyViewController.presentViewController(viewController: transitionViewController,
                                                  animated: false,
                                                  completion: nil)
    }
}
