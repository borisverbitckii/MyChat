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
    case auth, register // состояния контроллера, чтобы отображать вид авторизации или регистрации
}

enum SubmitButtonState {
    case enable, disable // для включения выключения submitButton
}

enum AlertControllerType {
    case allFields, onlyPasswordsFields // типы генерируемых алертконтроллеров
    // allFields - для того, чтобы вывести "вы ввели не правильный логин и пароль"
    // onlyPasswordsFields - для того, чтобы вывести "пароли не совпадают"
}

private enum RegisterViewModelLocalConstants {
    static let buttonOpacityIsNotOpaque: CGFloat = 0.3
    static let buttonOpacityIsOpaque: CGFloat = 1
}

protocol RegisterViewModelProtocol {

    // Общие
    var viewControllerState: BehaviorRelay<RegisterViewControllerState> { get set }
    func presentTabBarController()
    func checkTextfields(name: String?,
                         password: String?,
                         secondPassword: String?)
    // Текстфилды
    var nameTextfieldText: PublishRelay<String> { get }
    var passwordTextfieldText: PublishRelay<String> { get }
    var secondPasswordTextfieldText: PublishRelay<String> { get }
    func cleanTextfields()
    func becomeFirstResponderOrClearOffTextfields(nameTextField: UITextField,
                                                  passwordTestField: UITextField,
                                                  passwordSecondTimeTextfield: UITextField,
                                                  presenter: UIViewController)
    // submitButton
    var submitButtonState: BehaviorRelay<SubmitButtonState> { get } // Активна или не активна
    var submitButtonTitle: BehaviorRelay<String> { get } // Для смены заголовка "аворизироваться" и "зарегистрироваться"
    var submitButtonIsEnable: BehaviorRelay<Bool> { get } // Включение/выключение кнопки
    var submitButtonAlpha: PublishRelay<CGFloat> { get } // Прозрачность кнопки
    func submitButtonChangeIsEnable() // Включение/выключение кнопки
    func submitButtonChangeAlpha() // Прозрачность кнопки
    func disableSubmitButton() // Выключение кнопки
    // changeStateButton
    var changeStateButtonTitle: BehaviorRelay<String> { get } // Заголовок для кнопки
    func changeViewControllerState() // Поведение при клике на кнопку переключения состояния контроллера
    // Обе кнопки
    func changeButtonsTitle() // Смена текста кнопок в зависимости от состояния контроллера
    // PasswordSecondTimeTextfield
    var passwordSecondTimeTextfieldIsHidden: BehaviorRelay<Bool> { get } // Скрытие/отобраение 3 текстфилда
    func secondTimeTextfieldIsHiddenToggle() // Скрытие/отобраение 3 текстфилда
    // ErrorPasswordText
    var errorPasswordLabelText: BehaviorRelay<String> { get }
    // Заголовок для лейбла, который пишет, что пароли не совпадают при регистрации
    var errorPasswordLabelState: BehaviorRelay<Bool> { get }
    // Включение/выключение лейбла, который пишет, что пароли не совпадают при регистрации
    func disableErrorLabel() // выключение лейбла, который про то, что пароли не совпадают
}

final class RegisterViewModel {

    // MARK: - Public properties
    // Все описания пропертей сверху в протоколе
    var viewControllerState = BehaviorRelay(value: RegisterViewControllerState.auth)
    // Submit button
    var submitButtonState = BehaviorRelay(value: SubmitButtonState.disable)
    var submitButtonTitle = BehaviorRelay<String>(value: Text.button(.auth).text)
    var submitButtonIsEnable = BehaviorRelay<Bool>(value: false)
    var submitButtonAlpha = PublishRelay<CGFloat>()
    // СhangeStateButton
    var changeStateButtonTitle = BehaviorRelay<String>(value: Text.button(.register).text)
    // passwordSecondTimeTextfield
    var passwordSecondTimeTextfieldIsHidden = BehaviorRelay<Bool>(value: false)
    // Textfields
    var nameTextfieldText = PublishRelay<String>()
    var passwordTextfieldText = PublishRelay<String>()
    var secondPasswordTextfieldText = PublishRelay<String>()

    // ErrorPasswordsLabel
    var errorPasswordLabelText = BehaviorRelay<String>(value: Text.passwordErrorLabel.text)
    var errorPasswordLabelState = BehaviorRelay<Bool>(value: true)

    // MARK: - Private properties
    private let coordinator: CoordinatorProtocol // для флоу между контролллеров
    private let authManager: AuthManagerProtocol // менеджер для регистрации/авторизации

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
            // Включаем/выключаем кнопку исходя из содержания всех филдов для состояния "регистрация"
            ((name != "" && (password == secondPassword)) && password != "" && secondPassword != "")
            ? submitButtonState.accept(.enable)
            : submitButtonState.accept(.disable)

            // Подсветка, что пароли при регистрации не совпадают (не алерт)
            password != secondPassword && (password != "" && secondPassword != "")
            ? errorPasswordLabelState.accept(false)
            : errorPasswordLabelState.accept(true)

        } else {
            // Включаем/выключаем кнопку исходя из содержания всех филдов для состояния "авторизация"
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
            // Когда ошибка логина и пароля (не удалось авторизироваться)
            alertController.message = Text.alertControllerMessage(.authError).text
        case .onlyPasswordsFields:
            // Когда не совпали пароли
            alertController.message = Text.alertControllerMessage(.registerError).text
        }

        let okAction = UIAlertAction(title: Text.alertAction(.okAction).text, style: .default) { _ in
            alertController.dismiss(animated: true)
        }

        alertController.addAction(okAction)
        return alertController
    }

    func changeViewControllerState() { // Поведение при клике на кнопку переключения состояния контроллера
        viewControllerState.value == .register
        ? viewControllerState.accept(.auth)
        : viewControllerState.accept(.register)
    }

    func changeButtonsTitle() {
        // Смена заголовков кнопок при смене состояния контроллера между "авторизация" и "регистрация"
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
        // Включение выключение текстфилда с дублированием пароля
        let value = passwordSecondTimeTextfieldIsHidden.value
        passwordSecondTimeTextfieldIsHidden.accept(!value)
    }

    func submitButtonChangeIsEnable() {
        // Смена состояния активного и не активного для submitButton
        switch submitButtonState.value {
        case .enable:
            submitButtonIsEnable.accept(true)
        case .disable:
            submitButtonIsEnable.accept(false)
        }
    }

    func disableSubmitButton() {
        submitButtonState.accept(.disable)
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
        // Смена прозрачности для submitButton
        switch submitButtonState.value {
        case .enable:
            submitButtonAlpha.accept(RegisterViewModelLocalConstants.buttonOpacityIsOpaque)
        case .disable:
            submitButtonAlpha.accept(RegisterViewModelLocalConstants.buttonOpacityIsNotOpaque)
        }
    }

    func becomeFirstResponderOrClearOffTextfields(nameTextField: UITextField,
                                                  passwordTestField: UITextField,
                                                  passwordSecondTimeTextfield: UITextField,
                                                  presenter: UIViewController) {

        if nameTextField.text != ""
            && passwordTestField.text != ""
            && passwordSecondTimeTextfield.text != "" {

            passwordTestField.becomeFirstResponder()
            // в случае, если пароли не совпадают при регистрации,
            // респондером становится текст филд с паролем, а не филд с его дублированием
            presenter.present(generateAlertController(type: .onlyPasswordsFields),
                              animated: true) // алертКонтроллер с ошибкой
            cleanPasswordsTextfields()
        } else {
            // Здесь решается, какой из филдов станет респондером (один из пустых)
            let newTextfieldFirstResponder = [nameTextField,
                                           passwordTestField,
                                           passwordSecondTimeTextfield].first { $0.text == ""}

            if newTextfieldFirstResponder?.isFirstResponder == false {
                newTextfieldFirstResponder?.becomeFirstResponder()
            }
        }
    }
}
