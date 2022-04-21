//
//  NetworkManager.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

public protocol NetworkManagerProtocol: NetworkManagerChatListProtocol {

}

public protocol NetworkManagerChatListProtocol {

}

public final class NetworkManager {

    // MARK: Init
    public init() {}

}

// MARK: - extension + NetworkManagerProtocol
extension NetworkManager: NetworkManagerProtocol {

}

// MARK: - extension + NetworkManagerChatListProtocol
extension NetworkManager: NetworkManagerChatListProtocol {

}
