//
//  ManagerFactory.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Foundation

protocol ManagerFactoryProtocol {
    func getAuthManager() -> AuthManagerProtocol
    func getNetworkManager() -> NetworkManagerProtocol
    func getStorageManager() -> StorageManagerProtocol
}

final class ManagerFactory {
    //MARK: - Private properties
    private let networkManager = NetworkManager()
    private let storageManager = StorageManager()
    private let authManager = AuthManager()
    
}

//MARK: - extension + ManagerFactoryProtocol
extension ManagerFactory: ManagerFactoryProtocol {
    func getNetworkManager() -> NetworkManagerProtocol {
        networkManager
    }
    
    func getStorageManager() -> StorageManagerProtocol {
        storageManager
    }
    
    func getAuthManager() -> AuthManagerProtocol {
        authManager
    }
}
