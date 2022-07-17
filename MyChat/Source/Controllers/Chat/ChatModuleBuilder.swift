//
//  ChatModuleBuilder.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Models
import UIKit

final class ChatModuleBuilder {

    func build(receiverUser: ChatUser,
               managerFactory: ManagerFactoryForModulesProtocol,
               coordinator: CoordinatorProtocol,
               texts: @escaping (ChatViewControllerTexts) -> String,
               palette: @escaping (ChatViewControllerPalette) -> UIColor,
               fonts: @escaping (ChatViewControllerFonts) -> UIFont) -> ChatViewController {
        let viewModel = ChatViewModel(receiverUser: receiverUser,
                                      coordinator: coordinator,
                                      webSocketsFacade: managerFactory.getWebSocketsFlowFacade(),
                                      storageManager: managerFactory.getStorageManager(),
                                      imageCacheManager: managerFactory.getImageCacheManager(),
                                      texts: texts,
                                      palette: palette,
                                      fonts: fonts)
        let uiElements = ChatUI()
        let viewController = ChatViewController(uiElements: uiElements,
                                                chatViewModel: viewModel)
        return viewController
    }
}
