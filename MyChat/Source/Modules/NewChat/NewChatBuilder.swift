//
//  NewChatBuilder.swift
//  MyChat
//
//  Created by Борис on 14.02.2022.
//

final class NewChatModuleBuilder {

    func build(coordinator: CoordinatorProtocol) -> NewChatViewController {
        let viewModel = NewChatViewModel(coordinator: coordinator)
        let viewController = NewChatViewController(newChatViewModel: viewModel)
        return viewController
    }
}
