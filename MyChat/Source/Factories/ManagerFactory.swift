//
//  ManagerFactory.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Services
import Messaging

/*
 Фабрика всех сервисов в приложении
 Создет единые инстансы, к которым можно обратиться из любого места в приложении
 */

protocol ManagerFactoryForModulesProtocol {
    func getAuthFacade() -> AuthFacadeProtocol
    func getAuthManager() -> AuthManager
    func getImageCacheManager() -> ImageCacheManagerProtocol
    func getStorageManager() -> StorageManagerProtocol
    func getWebSocketsFlowFacade() -> WebSocketsFlowFacade
    func getRemoteDataBaseManager() -> RemoteDataBaseManagerProtocol
    func getRemoteFileStorageManager() -> RemoteFileStorageManagerProtocol
}

protocol ManagerFactoryGlobalProtocol {
    func getConfigManager() -> ConfigureManagerProtocol
    func getPushNotificationManager() -> PushNotificationManagerProtocol
}

final class ManagerFactory {

    // MARK: - Private properties
    private lazy var storageManager = StorageManager()
    private lazy var authManager = AuthManager()
    private lazy var imageCacheManager = ImageCacheManager()
    private lazy var remoteDataBaseManager = RemoteDataBaseManager()
    private lazy var remoteFileStorageManager = RemoteFileStorageManager()
    private lazy var authFacade = AuthFacade(authManager: authManager,
                                             remoteDatabaseManager: remoteDataBaseManager)
    private lazy var pushNotificationsManager = PushNotificationManager()
    private lazy var configManager = ConfigureManager()
    private lazy var webSocketsFlowFacade = WebSocketsFlowFacade(
        webSocketsConnector: WebSocketsConnector(),
        remoteDataBaseManager: remoteDataBaseManager,
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

    func getImageCacheManager() -> ImageCacheManagerProtocol {
        imageCacheManager
    }

    func getAuthFacade() -> AuthFacadeProtocol {
        authFacade
    }

    func getWebSocketsFlowFacade() -> WebSocketsFlowFacade {
        webSocketsFlowFacade
    }

    func getRemoteDataBaseManager() -> RemoteDataBaseManagerProtocol {
        remoteDataBaseManager
    }

    func getRemoteFileStorageManager() -> RemoteFileStorageManagerProtocol {
        remoteFileStorageManager
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
