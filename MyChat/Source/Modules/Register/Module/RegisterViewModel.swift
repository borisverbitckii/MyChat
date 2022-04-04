//
//  RegisterViewModel.swift
//  MyChat
//
//  Created by Борис on 14.02.2022.
//

import RxRelay
import RxSwift
import AsyncDisplayKit

enum RegisterViewControllerState {
    case auth, register // состояния контроллера, чтобы отображать вид авторизации или регистрации
}

enum SubmitButtonState {
    case enable, disable // для включения выключения submitButton
}

enum AlertControllerType {
    case allFields, onlyPasswordsFields
    /*Типы генерируемых алертконтроллеров
        - allFields - для того, чтобы вывести "вы ввели не правильный логин и пароль"
        - onlyPasswordsFields - для того, чтобы вывести "пароли не совпадают" */
}

private enum RegisterViewModelLocalConstants {
    // Прозрачность/непрозрачнсть submitButton
    static let buttonOpacityIsNotOpaque: CGFloat = 0.3
    static let buttonOpacityIsOpaque: CGFloat = 1
}

protocol RegisterViewModelProtocol {
    var input: RegisterViewModelInput { get }
    var output: RegisterViewModelOutput { get }
}

protocol RegisterViewModelInput {
    func presentTabBarController()
    func checkTextfields(name: String?,
                         password: String?,
                         secondPassword: String?)
    func cleanTextfields()
    func becomeFirstResponderOrClearOffTextfields(nameTextField: ASTextFieldNode,
                                                  passwordTestField: ASTextFieldNode,
                                                  passwordSecondTimeTextfield: ASTextFieldNode,
                                                  presenter: UIViewController)
    func submitButtonChangeIsEnable()        // Включение/выключение кнопки submitButton
    func submitButtonChangeAlpha()           // Прозрачность кнопки
    func disableSubmitButton()               // Выключение кнопки submitButton
    func changeViewControllerState()         // Поведение при клике на кнопку переключения состояния контроллера
    func changeButtonsTitle()                // Смена текста кнопок в зависимости от состояния контроллера
    func secondTimeTextfieldIsHiddenToggle() // Скрытие/отобраение 3 текстфилда
    func disableErrorLabel()                 // выключение лейбла, который про то, что пароли не совпадают
}

protocol RegisterViewModelOutput {
    var viewControllerState: BehaviorRelay<RegisterViewControllerState> { get set }
    // Текстфилды
    var textfieldsFont: BehaviorRelay<UIFont> { get } // один шрифт на все текстфилды
        // nameTextfield
    var nameTextfieldText: PublishRelay<String> { get }
    var nameTextfieldPlaceholder: BehaviorRelay<String> { get }
        // passwordTextfield
    var passwordTextfieldText: PublishRelay<String> { get }
    var passwordTextfieldPlaceholder: BehaviorRelay<String> { get }
        // secondPasswordTextfield
    var secondPasswordTextfieldText: PublishRelay<String> { get }
    var secondPasswordTextfieldPlaceholder: BehaviorRelay<String> { get }
    var secondPasswordTextfieldIsHidden: BehaviorRelay<Bool> { get } // Скрытие/отобраение 3его текстфилда
    // submitButton
    var submitButtonState: BehaviorRelay<SubmitButtonState> { get } // Активна или не активна
    var submitButtonTitle: BehaviorRelay<(title: String, font: UIFont)> { get }
        // Для смены заголовка "аворизироваться" и "зарегистрироваться"
    var submitButtonIsEnable: BehaviorRelay<Bool> { get } // Включение/выключение кнопки
    var submitButtonAlpha: PublishRelay<CGFloat> { get } // Прозрачность кнопки
    // changeStateButton
    var changeStateButtonTitle: BehaviorRelay<(title: String, font: UIFont)> { get } // Заголовок для кнопки
    // errorPasswordText
    var errorPasswordLabel: BehaviorRelay<(text: String, font: UIFont)> { get } // шрифт для errorPasswordLabel
        // Заголовок для лейбла, который пишет, что пароли не совпадают при регистрации
    var errorPasswordLabelState: BehaviorRelay<Bool> { get }
        // Включение/выключение лейбла, который пишет, что пароли не совпадают при регистрации
}

final class RegisterViewModel: RegisterViewModelProtocol, RegisterViewModelOutput {

    // MARK: - Public properties
    var input: RegisterViewModelInput { return self }
    var output: RegisterViewModelOutput { return self }

    // Все описания пропертей сверху в протоколе output
    var viewControllerState = BehaviorRelay(value: RegisterViewControllerState.auth)
    // Submit button
    var submitButtonState = BehaviorRelay(value: SubmitButtonState.disable)
    var submitButtonTitle: BehaviorRelay<(title: String, font: UIFont)>
    var submitButtonIsEnable = BehaviorRelay<Bool>(value: false)
    var submitButtonAlpha = PublishRelay<CGFloat>()
    // СhangeStateButton
    var changeStateButtonTitle: BehaviorRelay<(title: String, font: UIFont)>
    // passwordSecondTimeTextfield
    var secondPasswordTextfieldIsHidden = BehaviorRelay<Bool>(value: false)
    // Textfields
    var textfieldsFont: BehaviorRelay<UIFont>
        // nameTextfield
    var nameTextfieldText = PublishRelay<String>()
    var nameTextfieldPlaceholder: BehaviorRelay<String>
        // passwordTextfield
    var passwordTextfieldText = PublishRelay<String>()
    var passwordTextfieldPlaceholder: BehaviorRelay<String>
        // secondPasswordTextfield
    var secondPasswordTextfieldText = PublishRelay<String>()
    var secondPasswordTextfieldPlaceholder: BehaviorRelay<String>
    // ErrorPasswordsLabel
    var errorPasswordLabel: BehaviorRelay<(text: String, font: UIFont)>
    var errorPasswordLabelState = BehaviorRelay<Bool>(value: true)

    // MARK: - Private properties
    private let coordinator: CoordinatorProtocol // Для флоу между контролллеров
    private let authManager: AuthManagerProtocol // Менеджер для регистрации/авторизации
    private let fonts: FontsProtocol             // Для применения шрифтов

    // MARK: - Init
    init(coordinator: CoordinatorProtocol,
         authManager: AuthManagerProtocol,
         fonts: FontsProtocol) {
        self.coordinator = coordinator
        self.authManager = authManager
        self.fonts = fonts

        // Стандартные значения для UI
        let submitButtonTitleText = Text.button(.auth).text
        let submitButtonTitleFont = fonts.buttons()(.submitButton)
        self.submitButtonTitle = BehaviorRelay<(title: String,
                                                font: UIFont)>(value: (
                                                    title: submitButtonTitleText,
                                                    font: submitButtonTitleFont))

        let changeStateButtonText = Text.button(.register).text
        let changeStateButtonFont = fonts.buttons()(.changeStateButton)
        self.changeStateButtonTitle = BehaviorRelay<(title: String,
                                                     font: UIFont)>(value: (
                                                        title: changeStateButtonText,
                                                        font: changeStateButtonFont))
        // nameTextfield
        let nameTextFieldPlaceholderText = Text.textfield(.username).text
        self.nameTextfieldPlaceholder = BehaviorRelay<String>(value: nameTextFieldPlaceholderText)

        // passwordTextfield
        let passwordPlaceholderText = Text.textfield(.password(.first)).text
        self.passwordTextfieldPlaceholder = BehaviorRelay<String>(value: passwordPlaceholderText)

        // secondPasswordTextfield
        let secondPassPlaceholderText = Text.textfield(.password(.second)).text
        self.secondPasswordTextfieldPlaceholder = BehaviorRelay<String>(value: secondPassPlaceholderText)

        // Для всех текстфилдов
        self.textfieldsFont = BehaviorRelay<UIFont>(value: fonts.textfields()(.registerTextfield))

        // errorPasswordLabel
        errorPasswordLabel = BehaviorRelay<(text: String,
                                            font: UIFont)>(value: (
                                                text: Text.passwordErrorLabel.text,
                                                font: fonts.labels()(.registerErrorLabel)))
    }

}

// MARK: - RegisterViewModel + RegisterViewModelInput -
extension RegisterViewModel: RegisterViewModelInput {

    // MARK: - Public Methods -
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

    func cleanTextfields() {
        nameTextfieldText.accept("")
        passwordTextfieldText.accept("")
        secondPasswordTextfieldText.accept("")
    }

    func becomeFirstResponderOrClearOffTextfields(nameTextField: ASTextFieldNode,
                                                  passwordTestField: ASTextFieldNode,
                                                  passwordSecondTimeTextfield: ASTextFieldNode,
                                                  presenter: UIViewController) {

        if nameTextField.text != ""
            && passwordTestField.text != ""
            && passwordSecondTimeTextfield.text != "" {

            passwordTestField.textField.becomeFirstResponder()
            // в случае, если пароли не совпадают при регистрации,
            // респондером становится текст филд с паролем, а не филд с его дублированием
            presenter.present(generateAlertController(type: .onlyPasswordsFields),
                              animated: true) // алертКонтроллер с ошибкой
            errorPasswordLabelState.accept(true) // true == isHidden
            cleanPasswordsTextfields()
        } else {
            // Здесь решается, какой из филдов станет респондером (один из пустых)
            let textfields = [nameTextField,
                              passwordTestField,
                              passwordSecondTimeTextfield]
            let newTextfieldFirstResponder = textfields.first {
                $0.text == ""
            }

            guard let newTextfieldFirstResponder = newTextfieldFirstResponder else { return }
            newTextfieldFirstResponder.textField.becomeFirstResponder()
        }
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

    func submitButtonChangeAlpha() {
        // Смена прозрачности для submitButton
        switch submitButtonState.value {
        case .enable:
            submitButtonAlpha.accept(RegisterViewModelLocalConstants.buttonOpacityIsOpaque)
        case .disable:
            submitButtonAlpha.accept(RegisterViewModelLocalConstants.buttonOpacityIsNotOpaque)
        }
    }

    func disableSubmitButton() {
        submitButtonState.accept(.disable)
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
            submitButtonTitle.accept((title: Text.button(.auth).text, font: fonts.buttons()(.submitButton)))
            changeStateButtonTitle.accept((Text.button(.register).text, fonts.buttons()(.changeStateButton)))
        case .register:
            submitButtonTitle.accept((Text.button(.register).text, font: fonts.buttons()(.submitButton)))
            changeStateButtonTitle.accept((Text.button(.auth).text, fonts.buttons()(.changeStateButton)))
        }
    }

    func secondTimeTextfieldIsHiddenToggle() {
        // Включение выключение текстфилда с дублированием пароля
        let value = secondPasswordTextfieldIsHidden.value
        secondPasswordTextfieldIsHidden.accept(!value)
    }

    func disableErrorLabel() {
        errorPasswordLabelState.accept(true)
    }

    func cleanPasswordsTextfields() {
        passwordTextfieldText.accept("")
        secondPasswordTextfieldText.accept("")
    }

    // MARK: - Private Methods -
    @discardableResult private func generateAlertController(type: AlertControllerType) -> UIAlertController {

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
}
