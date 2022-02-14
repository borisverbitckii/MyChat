//
//  TabBarControllerViewModel.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

protocol TabBarControllerViewModelProtocol {
    func presentSplashModule(transitionHandler: TransitionHandler)
}

final class TabBarControllerViewModel {
    
    //MARK: - Private properties
    private let coordinator: CoordinatorProtocol
    
    //MARK: - Init
    init(coordinator: CoordinatorProtocol) {
        self.coordinator = coordinator
    }
}

//MARK: - extension + TabBarControllerViewModelProtocol
extension TabBarControllerViewModel: TabBarControllerViewModelProtocol {
    
    func presentSplashModule(transitionHandler: TransitionHandler) {
        coordinator.presentSplashViewController(transitionHandler: transitionHandler)
    }
}


