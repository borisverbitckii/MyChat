//
//  NetworkManager.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Foundation

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

// MARK: - extension + NetworkManagerСontactListProtocol
extension NetworkManager: NetworkManagerChatListProtocol {

}
