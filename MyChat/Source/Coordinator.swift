//
//  Coordinator.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Foundation
import UIKit

protocol CoordinatorProtocol: AnyObject {
    func injectWindow(window: UIWindow)
    func injectModuleFactory(moduleFactory: ModuleFactory)
    
    func presentTabBarViewController()
    func presentSplashViewController(transitionHandler: TransitionHandler)
}

final class Coordinator {
    
    //MARK: - Private properties
    private var window: UIWindow?
    private var moduleFactory: ModuleFactory?
}

//MARK: - extension + CoordinatorProtocol
extension Coordinator: CoordinatorProtocol {
    
    func injectWindow(window: UIWindow) {
        self.window = window
    }
    
    func injectModuleFactory(moduleFactory: ModuleFactory) {
        self.moduleFactory = moduleFactory
    }
    
    func presentTabBarViewController() {
        guard let window = window else { return }
        window.rootViewController = moduleFactory?.getTabBarController()
        window.makeKeyAndVisible()
    }
    
    func presentSplashViewController(transitionHandler: TransitionHandler) {
        guard let moduleFactory = moduleFactory else { return }
        let splashViewController = moduleFactory.getSplashModule(coordinator: self)
        splashViewController.modalPresentationStyle = .fullScreen
        transitionHandler.presentViewController(viewController: splashViewController,
                                                animated: false,
                                                completion: nil)
    }
}
