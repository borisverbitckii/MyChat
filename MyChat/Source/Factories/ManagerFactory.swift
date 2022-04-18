//
//  ManagerFactory.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Services

protocol ManagerFactoryProtocol {
    func getAuthManager() -> AuthManager
    func getNetworkManager() -> NetworkManagerProtocol
    func getStorageManager() -> StorageManagerProtocol
}

final class ManagerFactory {
    // MARK: - Private properties
    private lazy var networkManager = NetworkManager()
    private lazy var storageManager = StorageManager()
    private lazy var authManager = AuthManager()
    private lazy var configureManager = ConfigureManager()

}

// MARK: - extension + ManagerFactoryProtocol
extension ManagerFactory: ManagerFactoryProtocol {
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
