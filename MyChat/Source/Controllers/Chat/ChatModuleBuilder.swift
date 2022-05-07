//
//  ChatModuleBuilder.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Models

final class ChatModuleBuilder {

    func build(chat: Chat,
               managerFactory: ManagerFactoryForModulesProtocol,
               coordinator: CoordinatorProtocol) -> ChatViewController {
        let viewModel = ChatViewModel(chat: chat,
                                      coordinator: coordinator,
                                      messagesFlowCoordinator: managerFactory.getWebSocketsFlowFacade())
        let uiElements = ChatUI()
        let viewController = ChatViewController(uiElements: uiElements, chatViewModel: viewModel)
        return viewController
    }
}
