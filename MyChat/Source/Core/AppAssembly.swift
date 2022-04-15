//
//  AppAssembly.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit
import RxSwift
import Models
import Services

final class AppAssembly {

    // MARK: Private Properties
    private let window: UIWindow
    /// Заглушка, чтобы не было мерцаний при переходе на splashViewController, пока грузится config
    private lazy var emptyViewController: UIViewController = {
        $0.view.backgroundColor = .white
        return $0
    }(UIViewController())

    private let configManager: ConfigureManagerProtocol
    private let bag = DisposeBag()

    // MARK: Init
    @discardableResult  init(window: UIWindow,
                             configManager: ConfigureManagerProtocol) {
        self.window = window
        self.configManager = configManager

        window.rootViewController = emptyViewController
        window.makeKeyAndVisible()
        configureApp()
    }

    // MARK: Private methods
    private func configureApp() {
        configManager.getConfigObserver()
            .observe(on: MainScheduler.instance)
            .subscribe {  result in

                var config: AppConfig?

                switch result {
                case .success(let conf):
                    config = conf
                case .failure(let error):
                    print(error) // TODO: Залогировать
                }

                let coordinator = Coordinator(window: self.window)
                let managerFactory = ManagerFactory()

                let moduleFactory = ModuleFactory(coordinator: coordinator,
                                                  managerFactory: managerFactory,
                                                  config: config)

                coordinator.injectModuleFactory(moduleFactory: moduleFactory)
                coordinator.presentSplashViewController(presenter: self.emptyViewController)
            }
            .disposed(by: bag)
    }
}
