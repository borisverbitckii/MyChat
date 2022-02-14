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
    private let showSplash: Bool
    
    //MARK: - Init
    init(coordinator: CoordinatorProtocol,
         showSplash: Bool) {
        self.coordinator = coordinator
        self.showSplash = showSplash
    }
}

//MARK: - extension + TabBarControllerViewModelProtocol
extension TabBarControllerViewModel: TabBarControllerViewModelProtocol {
    
    func presentSplashModule(transitionHandler: TransitionHandler) {
        print(showSplash)
        if showSplash {
            coordinator.presentSplashViewController(transitionHandler: transitionHandler)
            return
        }
    }
}


