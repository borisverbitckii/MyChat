//
//  ChatModuleBuilder.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Foundation

final class ChatModuleBuilder {
    
    func build(managerFactory: ManagerFactoryProtocol,
               coordinator: CoordinatorProtocol) -> ChatViewController {
        let viewModel = ChatViewModel(coordinator: coordinator)
        let viewController = ChatViewController(chatViewModel: viewModel)
        return viewController
    }
}
