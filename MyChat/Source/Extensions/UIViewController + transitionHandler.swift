//
//  UIViewController + transitionHandler.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit

protocol TransitionHandler {
    /// Протокол чтобы скрыть остальные методы UIViewController при переходах на другие VC
    func presentViewController(viewController: UIViewController,
                               animated: Bool,
                               completion: (() -> Void)?)
}

// MARK: - extension + TransitionHandler
extension UIViewController: TransitionHandler {
    func presentViewController(viewController: UIViewController,
                               animated: Bool,
                               completion: (() -> Void)?) {
        present(viewController, animated: animated, completion: completion)
    }
}
