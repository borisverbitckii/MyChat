//
//  Coordinator.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit
import Models
import Logger
import Services

private enum LocalConstants {
    static let animationDuration: TimeInterval = 0.3
}

protocol CoordinatorProtocol: AnyObject {
    func injectModuleFactory(moduleFactory: ModuleFactoryProtocol)

    func presentTabBarViewController(withChatUser user: ChatUser)
    func presentRegisterViewController(presenter: TransitionHandler)
    func presentNewChatViewController(presenter: TransitionHandler)
    func presentChatViewController(receiverUser: ChatUser, presenterVC: TransitionHandler)

    func pushChatViewController(receiverUser: ChatUser, presenterVC: TransitionHandler)
}

final class Coordinator {

    // MARK: Private properties
    private var window: UIWindow
    private var moduleFactory: ModuleFactoryProtocol?

    // MARK: Init
    init(window: UIWindow) {
        self.window = window
    }
}

// MARK: - Coordinator + CoordinatorProtocol -
extension Coordinator: CoordinatorProtocol {

    func injectModuleFactory(moduleFactory: ModuleFactoryProtocol) {
        self.moduleFactory = moduleFactory
    }

    func presentTabBarViewController(withChatUser user: ChatUser) {
        guard let tabBarController = moduleFactory?.getTabBarController(with: user) else { return }
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()

        UIView.transition(with: window,
                          duration: LocalConstants.animationDuration,
                          options: .transitionCrossDissolve,
                          animations: nil)
    }

    func presentRegisterViewController(presenter: TransitionHandler) {
        guard let registerViewController = self.moduleFactory?.getRegisterViewController() else { return }
        window.rootViewController = registerViewController
        window.makeKeyAndVisible()

        UIView.transition(with: window,
                          duration: LocalConstants.animationDuration,
                          options: .transitionCrossDissolve,
                          animations: nil)
    }

    func presentNewChatViewController(presenter: TransitionHandler) {
        guard let newChatViewController = moduleFactory?.getNewChatModule(coordinator: self,
                                                                          presentingViewController: presenter) else { return }
        presenter.presentViewController(viewController: newChatViewController, animated: true, completion: nil)

    }

    func presentChatViewController(receiverUser: ChatUser, presenterVC: TransitionHandler) {
        guard let chatViewController = moduleFactory?.getChatModule(receiverUser: receiverUser,
                                                                    coordinator: self) else { return }
        presenterVC.presentViewController(viewController: chatViewController, animated: true, completion: nil)
    }

    func pushChatViewController(receiverUser: ChatUser, presenterVC: TransitionHandler) {
        guard let chatViewController = moduleFactory?.getChatModule(receiverUser: receiverUser,
                                                                    coordinator: self) else { return }
        presenterVC.pushViewController(viewController: chatViewController, animated: true)
    }
}
