//
//  ChatModuleBuilder.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Models

final class ChatModuleBuilder {

    func build(receiverUser: ChatUser,
               managerFactory: ManagerFactoryForModulesProtocol,
               coordinator: CoordinatorProtocol) -> ChatViewController {
        let viewModel = ChatViewModel(receiverUser: receiverUser,
                                      coordinator: coordinator,
                                      webSocketsFacade: managerFactory.getWebSocketsFlowFacade(),
                                      storageManager: managerFactory.getStorageManager())
        let uiElements = ChatUI()
        let viewController = ChatViewController(uiElements: uiElements, chatViewModel: viewModel)
        return viewController
    }
}
