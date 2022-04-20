//
//  ManagerFactory.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Services

protocol ManagerFactoryForModulesProtocol {
    func getAuthManager() -> AuthManager
    func getNetworkManager() -> NetworkManagerProtocol
    func getStorageManager() -> StorageManagerProtocol
}

protocol ManagerFactoryGlobalProtocol {
    func getConfigManager() -> ConfigureManagerProtocol
    func getPushNotificationManager() -> PushNotificationManagerProtocol
}

final class ManagerFactory {
    // MARK: - Private properties
    private lazy var networkManager = NetworkManager()
    private lazy var storageManager = StorageManager()
    private lazy var authManager = AuthManager()
    private lazy var configureManager = ConfigureManager()
    private lazy var pushNotificationsManager = PushNotificationManager()
    private lazy var configManager = ConfigureManager()

}

// MARK: - extension + ManagerFactoryForModulesProtocol
extension ManagerFactory: ManagerFactoryForModulesProtocol {

    func getNetworkManager() -> NetworkManagerProtocol {
        networkManager
    }

    func getStorageManager() -> StorageManagerProtocol {
        storageManager
    }

    func getAuthManager() -> AuthManager {
        authManager
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
