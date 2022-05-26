//
//  NewChatBuilder.swift
//  MyChat
//
//  Created by Борис on 14.02.2022.
//

import UIKit

final class NewChatModuleBuilder {

    func build(coordinator: CoordinatorProtocol,
               presentingViewController: TransitionHandler,
               managers: ManagerFactoryForModulesProtocol,
               texts: @escaping (NewChatViewControllerTexts) -> String,
               palette: @escaping (NewChatViewControllerPalette) -> UIColor) -> NewChatViewController {
        let viewModel = NewChatViewModel(coordinator: coordinator,
                                         remoteDataBase: managers.getRemoteDataBaseManager(),
                                         presentingViewController: presentingViewController,
                                         texts: texts,
                                         palette: palette)
        let uiElements = NewChatUI()
        let viewController = NewChatViewController(newChatViewModel: viewModel,
                                                   uiElements: uiElements)
        return viewController
    }
}
