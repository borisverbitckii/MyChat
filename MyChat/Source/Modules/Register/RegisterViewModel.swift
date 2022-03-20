//
//  RegisterViewModel.swift
//  MyChat
//
//  Created by Борис on 14.02.2022.
//

import RxRelay
import RxSwift
import UIKit

enum RegisterViewControllerState {
    case auth, register
}

enum SubmitButtonState {
    case enable, disable
}

private enum RegisterViewModelLocalConstants {
    static let buttonOpacityIsNotOpaque: CGFloat = 0.3
    static let buttonOpacityIsOpaque: CGFloat = 1
}

protocol RegisterViewModelProtocol {

    // Common
    var viewControllerState: BehaviorRelay<RegisterViewControllerState> { get set }
    func presentTabBarController()
    func checkTextfields(name: String?,
                         password: String?,
                         secondPassword: String?)
    func showAlertController() -> UIAlertController
    // Textfields
    var nameTextfieldText: PublishRelay<String> { get }
    var passwordTextfieldText: PublishRelay<String> { get }
    var secondPasswordTextfieldText: PublishRelay<String> { get }
    func cleanTextfields()
    // Submit button
    var submitButtonState: BehaviorRelay<SubmitButtonState> { get }
    var submitButtonTitle: BehaviorRelay<String> { get }
    var submitButtonIsEnable: BehaviorRelay<Bool> { get }
    var submitButtonAlpha: PublishRelay<CGFloat> { get }
    func submitButtonIsEnableToggle()
    func submitButtonChangeAlpha()
    // ChangeStateButton
    var changeStateButtonTitle: BehaviorRelay<String> { get }
    // Both buttons
    func changeButtonsTitle()
    // PasswordSecondTimeTextfield
    var passwordSecondTimeTextfieldIsHidden: BehaviorRelay<Bool> { get }
    // SecondTextfield
    func secondTimeTextfieldIsHiddenToggle()
}

final class RegisterViewModel {

    // MARK: - Public properties
    var viewControllerState = BehaviorRelay(value: RegisterViewControllerState.register)
    // Submit button
    var submitButtonState = BehaviorRelay(value: SubmitButtonState.disable)
    var submitButtonTitle = BehaviorRelay<String>(value: Text.button(.register).text)
    var submitButtonIsEnable = BehaviorRelay<Bool>(value: true)
    var submitButtonAlpha = PublishRelay<CGFloat>()

    var changeStateButtonTitle = BehaviorRelay<String>(value: Text.button(.auth).text)
    var passwordSecondTimeTextfieldIsHidden = BehaviorRelay<Bool>(value: true)
    // Textfields
    var nameTextfieldText = PublishRelay<String>()
    var passwordTextfieldText = PublishRelay<String>()
    var secondPasswordTextfieldText = PublishRelay<String>()

    // MARK: - Private properties
    private let coordinator: CoordinatorProtocol
    private let authManager: AuthManagerProtocol

    // MARK: - Init
    init(coordinator: CoordinatorProtocol,
         authManager: AuthManagerProtocol) {
        self.coordinator = coordinator
        self.authManager = authManager
    }
}

// MARK: - extension + RegisterViewModelProtocol
extension RegisterViewModel: RegisterViewModelProtocol {
    func presentTabBarController() {
        coordinator.presentTabBarViewController(showSplash: false)
    }

    func checkTextfields(name: String?,
                         password: String?,
                         secondPassword: String?) {
        if viewControllerState.value == .register {
            (name != nil && password == secondPassword && password != "" && secondPassword != "")
            ? submitButtonState.accept(.enable)
            : submitButtonState.accept(.disable)
        } else {
            (name != "" && password != "")
            ? submitButtonState.accept(.enable)
            : submitButtonState.accept(.disable)
        }
    }

    func showAlertController() -> UIAlertController {
        let alertController = UIAlertController(title: Text.alertControllerTitle(.registrationError).text,
                                                message: Text.alertControllerMessage(.registrationError).text,
                                                preferredStyle: .alert)

        let okAction = UIAlertAction(title: Text.alertAction(.ok).text, style: .default) { _ in
            alertController.dismiss(animated: true)
        }

        alertController.addAction(okAction)
        return alertController
    }

    func changeButtonsTitle() {
        switch viewControllerState.value {
        case .auth:
            submitButtonTitle.accept(Text.button(.auth).text)
            changeStateButtonTitle.accept(Text.button(.register).text)
        case .register:
            submitButtonTitle.accept(Text.button(.register).text)
            changeStateButtonTitle.accept(Text.button(.auth).text)
        }
    }

    func secondTimeTextfieldIsHiddenToggle() {
        let value = passwordSecondTimeTextfieldIsHidden.value
        passwordSecondTimeTextfieldIsHidden.accept(!value)
    }

    func submitButtonIsEnableToggle() {
        let value = submitButtonIsEnable.value
        submitButtonIsEnable.accept(!value)
    }

    func cleanTextfields() {
        nameTextfieldText.accept("")
        passwordTextfieldText.accept("")
        secondPasswordTextfieldText.accept("")
    }

    func submitButtonChangeAlpha() {
        switch submitButtonState.value {
        case .enable:
            submitButtonAlpha.accept(RegisterViewModelLocalConstants.buttonOpacityIsOpaque)
        case .disable:
            submitButtonAlpha.accept(RegisterViewModelLocalConstants.buttonOpacityIsNotOpaque)
        }
    }
}
