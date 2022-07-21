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

    func presentRegisterViewController()
    func presentAgreementsViewController(presenter: TransitionHandler, type: AgreementsType)
    func presentProfileViewController(chatUser: ChatUser,
                                      presenter: TransitionHandler)
    func presentChatsListNavigationController(withChatUser user: ChatUser)
    func presentNewChatViewController(presenter: TransitionHandler)
    func presentImagePickerController(presenter: TransitionHandler,
                                      delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate,
                                      source: UIImagePickerController.SourceType)
    func presentAlertController(style: UIAlertController.Style,
                                title: String,
                                message: String,
                                actions: [UIAlertAction],
                                presenter: TransitionHandler)
    func pushSettingsViewController(chatUser: ChatUser,
                                    presenter: TransitionHandler)
    func pushProfileViewController(chatUser: ChatUser,
                                   presenter: TransitionHandler)
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

    // Present

    func presentRegisterViewController() {
        guard let registerViewController = moduleFactory?.getRegisterViewController() else { return }
        window.rootViewController = registerViewController
        window.makeKeyAndVisible()

        UIView.transition(with: window,
                          duration: LocalConstants.animationDuration,
                          options: .transitionCrossDissolve,
                          animations: nil)
    }

    func presentAgreementsViewController(presenter: TransitionHandler, type: AgreementsType) {
        guard let agreementsViewController = moduleFactory?.getAgreementsViewController(type: type) else { return }
        presenter.presentViewController(viewController: agreementsViewController, animated: true, completion: nil)
    }

    func presentProfileViewController(chatUser: ChatUser,
                                      presenter: TransitionHandler) {
        guard let profileViewController = moduleFactory?.getProfileViewController(source: .byRegisterVC,
                                                                                  chatUser: chatUser) else { return }
        profileViewController.modalPresentationStyle = .fullScreen
        presenter.presentViewController(viewController: profileViewController, animated: true, completion: nil)
    }

    func presentChatsListNavigationController(withChatUser user: ChatUser) {
        guard let chatsListViewController = moduleFactory?.getChatsListModule(coordinator: self,
                                                                              user: user) else { return }
        window.rootViewController = chatsListViewController
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

    func presentImagePickerController(presenter: TransitionHandler,
                                      delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate,
                                      source: UIImagePickerController.SourceType) {
        guard let imagePickerController = moduleFactory?.getImagePickerController(delegatе: delegate,
                                                                                  source: source) else { return }
        presenter.presentViewController(viewController: imagePickerController,
                                        animated: true, completion: nil)
    }

    func presentAlertController(style: UIAlertController.Style,
                                title: String,
                                message: String,
                                actions: [UIAlertAction],
                                presenter: TransitionHandler) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        for action in actions {
            alertController.addAction(action)
        }
        presenter.presentViewController(viewController: alertController, animated: true, completion: nil)
    }

    // Push

    func pushSettingsViewController(chatUser: ChatUser, presenter: TransitionHandler) {
        guard let settingsViewController = moduleFactory?.getSettingsModule(chatUser: chatUser,
                                                                            coordinator: self) else { return }
        presenter.pushViewController(viewController: settingsViewController, animated: true)
    }

    func pushProfileViewController(chatUser: ChatUser,
                                   presenter: TransitionHandler) {
        guard let profileViewController = moduleFactory?.getProfileViewController(source: .bySettingsVC,
                                                                                  chatUser: chatUser) else { return }
        presenter.pushViewController(viewController: profileViewController, animated: true)

    }

    func pushChatViewController(receiverUser: ChatUser, presenterVC: TransitionHandler) {
        guard let chatViewController = moduleFactory?.getChatModule(receiverUser: receiverUser,
                                                                    coordinator: self) else { return }
        presenterVC.pushViewController(viewController: chatViewController, animated: true)
    }
}
