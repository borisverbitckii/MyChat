//
//  ManagerFactory.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Services
import Messaging

protocol ManagerFactoryForModulesProtocol {
    func getAuthManager() -> AuthManager
    func getStorageManager() -> StorageManagerProtocol
    func getWebSocketsFlowFacade() -> WebSocketsFlowFacade
}

protocol ManagerFactoryGlobalProtocol {
    func getConfigManager() -> ConfigureManagerProtocol
    func getPushNotificationManager() -> PushNotificationManagerProtocol
}

final class ManagerFactory {

    // MARK: - Private properties
    private lazy var storageManager = StorageManager()
    private lazy var authManager = AuthManager()
    private lazy var configureManager = ConfigureManager()
    private lazy var pushNotificationsManager = PushNotificationManager()
    private lazy var configManager = ConfigureManager()
    private lazy var webSocketsFlowFacade = WebSocketsFlowFacade(
        webSocketsConnector: WebSocketsConnector(),
        storageManager: storageManager)

}

// MARK: - extension + ManagerFactoryForModulesProtocol
extension ManagerFactory: ManagerFactoryForModulesProtocol {

    func getStorageManager() -> StorageManagerProtocol {
        storageManager
    }

    func getAuthManager() -> AuthManager {
        authManager
    }
    func getWebSocketsFlowFacade() -> WebSocketsFlowFacade {
        webSocketsFlowFacade
    }
}

// MARK: - extension + ManagerFactoryGlobalProtocol -
extension ManagerFactory: ManagerFactoryGlobalProtocol {

    func getConfigManager() -> ConfigureManagerProtocol {
        configManager
    }

    func getPushNotificationManager() -> PushNotificationManagerProtocol {
        pushNotificationsManager
    }
}
