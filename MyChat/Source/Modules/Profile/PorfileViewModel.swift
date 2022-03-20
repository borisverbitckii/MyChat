//
//  PorfileViewModel.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Foundation

enum ProfileViewControllerState {
    case normal, edit
}

protocol ProfileViewModelProtocol {
    var state: ProfileViewControllerState { get set }
}

final class ProfileViewModel {

    // MARK: - Public properties
    var state: ProfileViewControllerState = .normal

    // MARK: - Private properties
    private let coordinator: CoordinatorProtocol

    // MARK: - Init
    init(coordinator: CoordinatorProtocol) {
        self.coordinator = coordinator
    }

}

// MARK: - extension + ProfileViewModelProtocol
extension ProfileViewModel: ProfileViewModelProtocol {

}
