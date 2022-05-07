//
//  UIViewController + transitionHandler.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit

/// Протокол чтобы скрыть остальные методы UIViewController при переходах на другие VC
protocol TransitionHandler {

    func presentViewController(viewController: UIViewController,
                               animated: Bool,
                               completion: (() -> Void)?)

    func pushViewController(viewController: UIViewController, animated: Bool)
}

// MARK: - extension + TransitionHandler
extension UIViewController: TransitionHandler {
    func presentViewController(viewController: UIViewController,
                               animated: Bool,
                               completion: (() -> Void)?) {
        present(viewController, animated: animated, completion: completion)
    }

    func pushViewController(viewController: UIViewController, animated: Bool) {
        navigationController?.pushViewController(viewController, animated: animated)
    }
}
