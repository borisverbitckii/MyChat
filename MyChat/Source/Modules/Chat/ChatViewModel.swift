//
//  ChatViewModel.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Foundation

protocol ChatViewModelProtocol {
    
}

final class ChatViewModel {
    
    //MARK: - Private properties
    private let coordinator: CoordinatorProtocol
    
    //MARK: - Init
    init(coordinator: CoordinatorProtocol) {
        self.coordinator = coordinator
    }
}

//MARK: - extension + ChatViewModelProtocol
extension ChatViewModel: ChatViewModelProtocol {
    
}
