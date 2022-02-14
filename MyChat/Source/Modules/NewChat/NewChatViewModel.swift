//
//  NewChatViewModel.swift
//  MyChat
//
//  Created by Борис on 14.02.2022.
//

import Foundation

protocol NewChatViewModelProtocol {
    
}

final class NewChatViewModel {
    
    //MARK: - Private properties
    private let coordinator: CoordinatorProtocol
    
    //MARK: - Init
    init(coordinator: CoordinatorProtocol) {
        self.coordinator = coordinator
    }
    
}

//MARK: - extension + NewChatViewModelProtocol
extension NewChatViewModel: NewChatViewModelProtocol {
    
}
