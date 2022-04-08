//
//  NetworkManager.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Foundation

protocol NetworkManagerProtocol: NetworkManagerChatListProtocol {

}

protocol NetworkManagerChatListProtocol {

}

final class NetworkManager {

}

// MARK: - extension + NetworkManagerProtocol
extension NetworkManager: NetworkManagerProtocol {

}

// MARK: - extension + NetworkManagerСontactListProtocol
extension NetworkManager: NetworkManagerChatListProtocol {

}
