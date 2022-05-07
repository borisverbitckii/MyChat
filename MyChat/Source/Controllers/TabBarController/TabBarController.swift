//
//  TabBarController.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Logger
import AsyncDisplayKit

final class TabBarController: ASTabBarController {

    // MARK: - Private properties
    private let tabBarViewModel: TabBarControllerViewModelProtocol

    // MARK: - Init
    init(tabBarViewModel: TabBarControllerViewModelProtocol) {
        self.tabBarViewModel = tabBarViewModel
        super.init(nibName: nil, bundle: nil)
        delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isTranslucent = true
    }
}

// MARK: - extension + UITabBarControllerDelegate -
extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        Logger.log(to: .info, message: "В таббар контроллере выбран \(viewController.className)")
    }
}

// MARK: - extension + URLSessionWebSocketDelegate -
extension TabBarController: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        Logger.log(to: .info, message: "Подключился к web sockets")
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        Logger.log(to: .info, message: "Web sockets подключение завершено")
    }
}
