//
//  SplashViewModel.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit

protocol SplashViewModelProtocol {
}

final class SplashViewModel {
    
    //MARK: - Private properties
    private let coordinator: CoordinatorProtocol
    private let authManager: AuthManagerProtocol
    
    //MARK: - Init
    init(coordinator: CoordinatorProtocol,
         authManager: AuthManagerProtocol) {
        self.authManager = authManager
        self.coordinator = coordinator
    }
}

//MARK: - extension + SplashViewModelProtocol
extension SplashViewModel: SplashViewModelProtocol {
}
