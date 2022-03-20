//
//  ViewModel.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

protocol ChatsListViewModelProtocol {

}

final class ChatsListViewModel {

    // MARK: - Private properties
    private let coordinator: CoordinatorProtocol

    // MARK: - Init
    init(coordinator: CoordinatorProtocol) {
        self.coordinator = coordinator
    }
}

// MARK: - extension + ChatsListViewModelProtocol
extension ChatsListViewModel: ChatsListViewModelProtocol {

}
