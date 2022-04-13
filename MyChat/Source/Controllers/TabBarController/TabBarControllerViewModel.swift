//
//  TabBarControllerViewModel.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

protocol TabBarControllerViewModelProtocol {
}

final class TabBarControllerViewModel {

    // MARK: - Private properties
    private let coordinator: CoordinatorProtocol

    // MARK: - Init
    init(coordinator: CoordinatorProtocol) {
        self.coordinator = coordinator
    }
}

// MARK: - extension + TabBarControllerViewModelProtocol
extension TabBarControllerViewModel: TabBarControllerViewModelProtocol {

}
