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

enum AlertControllerType {
    case allFields, onlyPasswordsFields
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
    func removeLastFirstResponderTextfield()
    // Textfields
    var nameTextfieldText: PublishRelay<String> { get }
    var passwordTextfieldText: PublishRelay<String> { get }
    var secondPasswordTextfieldText: PublishRelay<String> { get }
    func cleanTextfields()
    func becomeFirstResponderOrClearOffTextfields(nameTextField: UITextField,
                                                  passwordTestField: UITextField,
                                                  passwordSecondTimeTextfield: UITextField,
                                                  presenter: UIViewController)
    // Submit button
    var submitButtonState: BehaviorRelay<SubmitButtonState> { get }
    var submitButtonTitle: BehaviorRelay<String> { get }
    var submitButtonIsEnable: BehaviorRelay<Bool> { get }
    var submitButtonAlpha: PublishRelay<CGFloat> { get }
    func submitButtonChangeState(to state: SubmitButtonState)
    func submitButtonChangeAlpha()
    // ChangeStateButton
    var changeStateButtonTitle: BehaviorRelay<String> { get }
    // Both buttons
    func changeButtonsTitle()
    // PasswordSecondTimeTextfield
    var passwordSecondTimeTextfieldIsHidden: BehaviorRelay<Bool> { get }
    // SecondTextfield
    func secondTimeTextfieldIsHiddenToggle()
    // ErrorPasswordText
    var errorPasswordLabelText: BehaviorRelay<String> { get }
    var errorPasswordLabelState: BehaviorRelay<Bool> { get }
    func errorLabelIsEnableToggle()
    func disableErrorLabel()
}

final class RegisterViewModel {

    // MARK: - Public properties
    var viewControllerState = BehaviorRelay(value: RegisterViewControllerState.auth)
    // Submit button
    var submitButtonState = BehaviorRelay(value: SubmitButtonState.disable)
    var submitButtonTitle = BehaviorRelay<String>(value: Text.button(.auth).text)
    var submitButtonIsEnable = BehaviorRelay<Bool>(value: false)
    var submitButtonAlpha = PublishRelay<CGFloat>()

    var changeStateButtonTitle = BehaviorRelay<String>(value: Text.button(.register).text)
    var passwordSecondTimeTextfieldIsHidden = BehaviorRelay<Bool>(value: false)
    // Textfields
    var nameTextfieldText = PublishRelay<String>()
    var passwordTextfieldText = PublishRelay<String>()
    var secondPasswordTextfieldText = PublishRelay<String>()

    // ErrorPasswordsLabel
    var errorPasswordLabelText = BehaviorRelay<String>(value: Text.passwordErrorLabel.text)
    var errorPasswordLabelState = BehaviorRelay<Bool>(value: true)

    // MARK: - Private properties
    private let coordinator: CoordinatorProtocol
    private let authManager: AuthManagerProtocol
    private var lastFirstResponderTextfield: UITextField?

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
        if submitButtonState.value == .enable {
            coordinator.presentTabBarViewController(showSplash: false)
        }
    }

    func checkTextfields(name: String?,
                         password: String?,
                         secondPassword: String?) {
        if viewControllerState.value == .register {
            ((name != "" && (password == secondPassword)) && password != "" && secondPassword != "")
            ? submitButtonState.accept(.enable)
            : submitButtonState.accept(.disable)

            // Подсветка, что пароли при регистрации не совпадают
            password != secondPassword && (password != "" && secondPassword != "")
            ? errorPasswordLabelState.accept(false)
            : errorPasswordLabelState.accept(true)

        } else {
            (name != "" && password != "")
            ? submitButtonState.accept(.enable)
            : submitButtonState.accept(.disable)
        }
    }

    @discardableResult func generateAlertController(type: AlertControllerType) -> UIAlertController {

        let alertController = UIAlertController(title: Text.alertControllerTitle(.registrationError).text,
                                                message: "",
                                                preferredStyle: .alert)

        switch type {
        case .allFields:
            alertController.message = Text.alertControllerMessage(.authError).text
        case .onlyPasswordsFields:
            alertController.message = Text.alertControllerMessage(.registerError).text
        }

        let okAction = UIAlertAction(title: Text.alertAction(.okAction).text, style: .default) { _ in
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

    // TODO: Зарефакторить нижние 3 метода
    func secondTimeTextfieldIsHiddenToggle() {
        let value = passwordSecondTimeTextfieldIsHidden.value
        passwordSecondTimeTextfieldIsHidden.accept(!value)
    }

    func submitButtonChangeState(to state: SubmitButtonState) {
        switch state {
        case .enable:
            submitButtonIsEnable.accept(true)
        case .disable:
            submitButtonIsEnable.accept(false)
        }
    }

    func errorLabelIsEnableToggle() {
        let value = errorPasswordLabelState.value
        errorPasswordLabelState.accept(!value)
    }

    func disableErrorLabel() {
        errorPasswordLabelState.accept(true)
    }

    func cleanTextfields() {
        nameTextfieldText.accept("")
        passwordTextfieldText.accept("")
        secondPasswordTextfieldText.accept("")
    }

    func cleanPasswordsTextfields() {
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

    func removeLastFirstResponderTextfield() {
        lastFirstResponderTextfield = nil
    }

    func becomeFirstResponderOrClearOffTextfields(nameTextField: UITextField,
                                                  passwordTestField: UITextField,
                                                  passwordSecondTimeTextfield: UITextField,
                                                  presenter: UIViewController) {

        if nameTextField.text != ""
            && passwordTestField.text != ""
            && passwordSecondTimeTextfield.text != "" {

            passwordTestField.becomeFirstResponder()
            lastFirstResponderTextfield = passwordTestField
            presenter.present(generateAlertController(type: .onlyPasswordsFields),
                              animated: true)
            cleanPasswordsTextfields()
        } else {
            let newTextfieldFirstResponder = [nameTextField,
                                           passwordTestField,
                                           passwordSecondTimeTextfield].first { $0.text == ""}

            if newTextfieldFirstResponder?.isFirstResponder == false {
                newTextfieldFirstResponder?.becomeFirstResponder()
                lastFirstResponderTextfield = newTextfieldFirstResponder
            }
        }
    }
}
