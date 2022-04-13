//
//  RegisterViewModel.swift
//  MyChat
//
//  Created by Борис on 14.02.2022.
//

import RxRelay
import RxSwift
import AsyncDisplayKit
import Services
import UIKit

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

// Для определения, по какой кнопке совершена попытка авторизации
enum RegisterAuthButtonType {
    case googleButton, facebookButton, submitButtonOrReturnButton
}

protocol RegisterViewModelProtocol: AnyObject {
    var input: RegisterViewModelInput { get }
    var output: RegisterViewModelOutput { get }
}

protocol RegisterViewModelInput {
    func presentTabBarController(withUsername username: String?,
                                 password: String?,
                                 sourceButtonType: RegisterAuthButtonType,
                                 presenter: UIViewController?)
    func checkTextfields(name: String?,
                         password: String?,
                         secondPassword: String?)
    func cleanTextfields()
    func becomeFirstResponderOrClearOffTextfields(nameTextField: ASTextFieldNode,
                                                  passwordTestField: ASTextFieldNode,
                                                  passwordSecondTimeTextfield: ASTextFieldNode,
                                                  presenter: TransitionHandler)
    func submitButtonChangeIsEnable()        // Включение/выключение кнопки submitButton
    func submitButtonChangeAlpha()           // Прозрачность кнопки
    func disableSubmitButton()               // Выключение кнопки submitButton
    func changeViewControllerState()         // Поведение при клике на кнопку переключения состояния контроллера
    func changeButtonsTitle()                // Смена текста кнопок в зависимости от состояния контроллера
    func secondTimeTextfieldIsHiddenToggle() // Скрытие/отобраение 3 текстфилда
    func disableErrorLabel()                 // выключение лейбла, который про то, что пароли не совпадают
}

protocol RegisterViewModelOutput {
    // viewController
    var viewControllerState: BehaviorRelay<RegisterViewControllerState> { get }
    var viewControllerBackgroundColor: BehaviorRelay<UIColor> { get }
    // submitButton
    var submitButtonState: BehaviorRelay<SubmitButtonState> { get } // Активна или не активна
    var submitButtonTitle: BehaviorRelay<(title: String, font: UIFont)> { get }
        // Для смены заголовка "аворизироваться" и "зарегистрироваться"
    var submitButtonIsEnable: BehaviorRelay<Bool> { get } // Включение/выключение кнопки
    var submitButtonColor: PublishRelay<UIColor> { get } // Прозрачность кнопки
    // changeStateButton
    var changeStateButtonTitle: BehaviorRelay<(title: String, font: UIFont)> { get } // Заголовок для кнопки
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
    // errorPasswordText
    var errorPasswordLabel: BehaviorRelay<(text: String, font: UIFont)> { get } // шрифт и текст для errorPasswordLabel
        // Заголовок для лейбла, который пишет, что пароли не совпадают при регистрации
    var errorPasswordLabelState: BehaviorRelay<Bool> { get }
        // Включение/выключение лейбла, который пишет, что пароли не совпадают при регистрации
    // orLabel
    var orLabel: BehaviorRelay<(text: String,            // swiftlint:disable:this large_tuple
                                font: UIFont,
                                color: UIColor)> { get } // шрифт и текст для orLabel
}

final class RegisterViewModel: RegisterViewModelProtocol, RegisterViewModelOutput {

    // MARK: Public properties
    var input: RegisterViewModelInput { return self }
    var output: RegisterViewModelOutput { return self }

    // Все описания пропертей сверху в протоколе output
    var viewControllerBackgroundColor: BehaviorRelay<UIColor>
    var viewControllerState = BehaviorRelay(value: RegisterViewControllerState.auth)
    // Submit button
    var submitButtonState = BehaviorRelay(value: SubmitButtonState.disable)
    var submitButtonTitle: BehaviorRelay<(title: String, font: UIFont)>
    var submitButtonIsEnable = BehaviorRelay<Bool>(value: false)
    var submitButtonColor = PublishRelay<UIColor>()
    // ChangeStateButton
    var changeStateButtonTitle: BehaviorRelay<(title: String, font: UIFont)>
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
    var secondPasswordTextfieldIsHidden = BehaviorRelay<Bool>(value: false)
    // errorPasswordsLabel
    var errorPasswordLabel: BehaviorRelay<(text: String, font: UIFont)>
    var errorPasswordLabelState = BehaviorRelay<Bool>(value: true)
    // orLabel
    var orLabel: BehaviorRelay<(text: String,
                                font: UIFont,
                                color: UIColor)>

    // MARK: Private properties
    private let disposeBag = DisposeBag()
    private let coordinator: CoordinatorProtocol                    // Для флоу между контролллерами
    private let authManager: AuthManagerRegisterProtocol            // Менеджер для регистрации/авторизации
    private let fonts: (RegisterViewControllerFonts) -> UIFont      // Для применения шрифтов
    private let texts: (RegisterViewControllerTexts) -> String      // Для установки всех текстов
    private let palette: (RegisterViewControllerPalette) -> UIColor // Для установки цветов

    // MARK: Init
    init(coordinator: CoordinatorProtocol,
         authManager: AuthManagerRegisterProtocol,
         fonts: @escaping (RegisterViewControllerFonts) -> UIFont,
         texts: @escaping (RegisterViewControllerTexts) -> String,
         palette: @escaping (RegisterViewControllerPalette) -> UIColor) {
        self.coordinator = coordinator
        self.authManager = authManager
        self.fonts = fonts
        self.texts = texts
        self.palette = palette

        // Стандартные значения для UI
        // viewController
        viewControllerBackgroundColor = BehaviorRelay<UIColor>(value: palette(.viewControllerBackgroundColor))

        // submitButton
        let submitButtonTitleText = texts(.authTextForButton)
        let submitButtonTitleFont = fonts(.submitButton)
        self.submitButtonTitle = BehaviorRelay<(title: String,
                                                font: UIFont)>(value: (
                                                    title: submitButtonTitleText,
                                                    font: submitButtonTitleFont))
        // changeStateButton
        let changeStateButtonText = texts(.sighUpTextForButton)
        let changeStateButtonFont = fonts(.changeStateButton)
        self.changeStateButtonTitle = BehaviorRelay<(title: String,
                                                     font: UIFont)>(value: (
                                                        title: changeStateButtonText,
                                                        font: changeStateButtonFont))
        // nameTextfield
        let nameTextFieldPlaceholderText = texts(.namePlaceholder)
        self.nameTextfieldPlaceholder = BehaviorRelay<String>(value: nameTextFieldPlaceholderText)

        // passwordTextfield
        let passwordPlaceholderText = texts(.passwordPlaceholder)
        self.passwordTextfieldPlaceholder = BehaviorRelay<String>(value: passwordPlaceholderText)

        // secondPasswordTextfield
        let secondPassPlaceholderText = texts(.secondPasswordPlaceholder)
        self.secondPasswordTextfieldPlaceholder = BehaviorRelay<String>(value: secondPassPlaceholderText)

        // Для всех текстфилдов
        self.textfieldsFont = BehaviorRelay<UIFont>(value: fonts(.registerTextfield))

        // errorPasswordLabel
        let errorPasswordText = texts(.errorPasswordLabel)
        errorPasswordLabel = BehaviorRelay<(text: String,
                                            font: UIFont)>(value: (
                                                text: errorPasswordText,
                                                font: fonts(.registerErrorLabel)))

        // orLabel
        let orLabelText = texts(.orLabelText)
        let orLabelFont = fonts(.registerOrLabel)
        let orLabelColor = palette(.orLabelTextColor)
        orLabel = BehaviorRelay<(text: String,
                                 font: UIFont,
                                 color: UIColor)>(value:
                                                    (text: orLabelText,
                                                     font: orLabelFont,
                                                     color: orLabelColor))
    }
}

// MARK: - RegisterViewModel + RegisterViewModelInput -
extension RegisterViewModel: RegisterViewModelInput {

    // MARK: Public Methods
    func presentTabBarController(withUsername username: String?,
                                 password: String?,
                                 sourceButtonType: RegisterAuthButtonType,
                                 presenter: UIViewController?) {

        switch viewControllerState.value {
        case .auth:
            switch sourceButtonType {
            case .googleButton:
                if let presenter = presenter {
                    authManager.signInWithGoogle(presenterVC: presenter)
                        .subscribe { [coordinator] authResult in
                            switch authResult {
                            case .success(let chatUser):
                                guard let chatUser = chatUser else { return }
                                coordinator.presentTabBarViewController(withChatUser: chatUser)
                            case .failure(let error):
                                print(error) // TODO: Обработать ошибки
                            }
                        } // TODO: Обработать ошибки для onFailure
                        .disposed(by: disposeBag)
                }
            case .facebookButton:
                if let presenter = presenter {
                    authManager.signInWithFacebook(presenterVC: presenter)
                        .subscribe { [coordinator] authResult in
                            switch authResult {
                            case .success(let chatUser):
                                guard let chatUser = chatUser else { return }
                                coordinator.presentTabBarViewController(withChatUser: chatUser)
                            case .failure(let error):
                                print(error) // TODO: Обработать ошибки
                            }
                        } // TODO: Обработать ошибки для onFailure
                        .disposed(by: disposeBag)
                }
            case .submitButtonOrReturnButton:
                guard let username = username, let password = password else { return }

                authManager.signIn(withEmail: username, password: password)
                    .subscribe { [coordinator] authResult in
                        switch authResult {
                        case .success(let chatUser):
                            guard let chatUser = chatUser else { return }
                            coordinator.presentTabBarViewController(withChatUser: chatUser)
                        case .failure(let error):
                            print(error) // TODO: Обработать ошибки
                        }
                    }
                    .disposed(by: disposeBag)
            }

        case .register:
            guard let username = username, let password = password else { return }
            authManager.createUser(withEmail: username, password: password)
                .subscribe { [coordinator] chatUser in
                    guard let chatUser = chatUser else { return }
                    coordinator.presentTabBarViewController(withChatUser: chatUser)
                } onFailure: { error in
                    print(error) // TODO: Обработать ошибки
                }
                .disposed(by: disposeBag)
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
                                                  presenter: TransitionHandler) {

        if nameTextField.text != ""
            && passwordTestField.text != ""
            && passwordSecondTimeTextfield.text != "" {

            passwordTestField.textField.becomeFirstResponder()
            // в случае, если пароли не совпадают при регистрации,
            // респондером становится текст филд с паролем, а не филд с его дублированием
            presenter.presentViewController(viewController: generateAlertController(type: .onlyPasswordsFields),
                                            animated: true,
                                            completion: nil) // алертКонтроллер с ошибкой
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
            submitButtonColor.accept(palette(.submitButtonActiveTintColor))
        case .disable:
            submitButtonColor.accept(palette(.submitButtonDisableTintColor))
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
            let submitButtonText = texts(.authTextForButton)
            let changeStateButtonText = texts(.sighUpTextForButton)
            submitButtonTitle.accept((title: submitButtonText,
                                      font: fonts(.submitButton)))
            changeStateButtonTitle.accept((title: changeStateButtonText,
                                           font: fonts(.changeStateButton)))
        case .register:
            let submitButtonText = texts(.sighUpTextForButton)
            let changeStateButtonText = texts(.authTextForButton)
            submitButtonTitle.accept((title: submitButtonText,
                                      font: fonts(.submitButton)))
            changeStateButtonTitle.accept((title: changeStateButtonText,
                                           font: fonts(.changeStateButton)))
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
    private func generateAlertController(type: AlertControllerType) -> UIAlertController {

        let alertControllerTitle = texts(.alertControllerTitle)
        let alertController = UIAlertController(title: alertControllerTitle,
                                                message: "",
                                                preferredStyle: .alert)

        switch type {
        case .allFields:
            // Когда ошибка логина и пароля (не удалось авторизироваться)
            alertController.message = texts(.alertControllerAuthError)
        case .onlyPasswordsFields:
            // Когда не совпали пароли
            alertController.message = texts(.alertControllerSignUpError)
        }

        let okActionText = texts(.alertControllerOKAction)
        let okAction = UIAlertAction(title: okActionText, style: .default) { _ in
            alertController.dismiss(animated: true)
        }

        alertController.addAction(okAction)
        return alertController
    }
}
