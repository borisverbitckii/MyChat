//
//  PorfileViewModel.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Foundation
import RxSwift
import RxRelay
import Services

enum ProfileViewControllerState {
    case normal, edit
}

protocol ProfileViewModelProtocol {
    var input: ProfileViewModelInputProtocol { get }
    var output: ProfileViewModelOutputProtocol { get }
}

protocol ProfileViewModelInputProtocol {
    func signOut(presenter: TransitionHandler)
}

protocol ProfileViewModelOutputProtocol {
    var state: ProfileViewControllerState { get }
    var viewControllerBackgroundColor: BehaviorRelay<UIColor> { get }
}

final class ProfileViewModel {

    // MARK: - Public properties
    var input: ProfileViewModelInputProtocol { return self }
    var output: ProfileViewModelOutputProtocol { return self }

    var state: ProfileViewControllerState = .normal

    // UI
    var viewControllerBackgroundColor: BehaviorRelay<UIColor>

    // MARK: - Private properties
    private let coordinator: CoordinatorProtocol
    private let authManager: AuthManagerProfileProtocol
    private let storageManager: StorageManagerProtocol
    private let webSocketConnector: WebSocketConnector
    private let disposeBag = DisposeBag()

    private let texts: (ProfileViewControllerTexts) -> String
    private let fonts: (ProfileViewControllerFonts) -> UIFont
    private let palette: (ProfileViewControllerPalette) -> UIColor

    // MARK: - Init
    init(coordinator: CoordinatorProtocol,
         authManager: AuthManagerProfileProtocol,
         storageManager: StorageManagerProtocol,
         webSocketsFacade: WebSocketsFlowFacade,
         texts: @escaping (ProfileViewControllerTexts) -> String,
         fonts: @escaping (ProfileViewControllerFonts) -> UIFont,
         palette: @escaping (ProfileViewControllerPalette) -> UIColor) {
        self.coordinator = coordinator
        self.authManager = authManager
        self.storageManager = storageManager
        self.webSocketConnector = webSocketsFacade

        self.texts = texts
        self.fonts = fonts
        self.palette = palette

        let vcBackgroundColor = palette(.profileViewControllerBackgroundColor)
        viewControllerBackgroundColor = BehaviorRelay<UIColor>(value: vcBackgroundColor)
    }
}

// MARK: - extension + ProfileViewModelProtocol
extension ProfileViewModel: ProfileViewModelProtocol {

}

// MARK: - extension + ProfileViewModelInputProtocol
extension ProfileViewModel: ProfileViewModelInputProtocol {
    func signOut(presenter: TransitionHandler) {
        authManager.signOut()
            .subscribe { [weak self, disposeBag] _ in
                self?.storageManager.removeEverything() // TODO: Сделать предупреждение, что все удалится
                    .subscribe { _ in
                        self?.coordinator.presentRegisterViewController(presenter: presenter)
                        self?.webSocketConnector.closeConnection()
                    } onFailure: { error in
                        // TODO: Обработать
                    }
                    .disposed(by: disposeBag)

            }
            .disposed(by: disposeBag)
    }
}

// MARK: - extension + ProfileViewModelOutputProtocol
extension ProfileViewModel: ProfileViewModelOutputProtocol {

}
