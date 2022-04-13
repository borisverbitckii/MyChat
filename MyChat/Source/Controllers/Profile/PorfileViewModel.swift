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

    // MARK: - Private properties
    private let coordinator: CoordinatorProtocol
    private let authManager: AuthManagerProfileProtocol
    private let disposeBag = DisposeBag()

    private let texts: (ProfileViewControllerTexts) -> String
    private let fonts: (ProfileViewControllerFonts) -> UIFont
    private let palette: (ProfileViewControllerPalette) -> UIColor

    var state: ProfileViewControllerState = .normal

    // UI
    var viewControllerBackgroundColor: BehaviorRelay<UIColor>

    // MARK: - Init
    init(coordinator: CoordinatorProtocol,
         authManager: AuthManagerProfileProtocol,
         texts: @escaping (ProfileViewControllerTexts) -> String,
         fonts: @escaping (ProfileViewControllerFonts) -> UIFont,
         palette: @escaping (ProfileViewControllerPalette) -> UIColor) {
        self.coordinator = coordinator
        self.authManager = authManager

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
            .subscribe { [coordinator] _ in
                coordinator.presentRegisterViewController(presenter: presenter)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - extension + ProfileViewModelOutputProtocol
extension ProfileViewModel: ProfileViewModelOutputProtocol {

}
