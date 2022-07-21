//
//  RegisterViewModel.swift
//  MyChat
//
//  Created by Борис on 14.02.2022.
//

import UI
import UIKit
import Models
import Logger
import RxRelay
import RxSwift
import RxCocoa
import Services
import CryptoKit
import Analytics
import AsyncDisplayKit
import AuthenticationServices

/// Состояния контроллера, чтобы отображать вид авторизации или регистрации
enum RegisterViewControllerState {
    case auth, register
}

/// Для включения выключения submitButton
enum SubmitButtonState {
    case enable, disable
}

enum TextFieldType {
    case email, password
}

enum AlertControllerType {
    /// Для того, чтобы вывести "вы ввели не правильный логин и пароль"
    case notCorrectLoginOrPassword
    /// Для того, чтобы вывести "пароли не совпадают"
    case passwordsNotTheSame
    /// Не сработала авторизация через google
    case googleAuth
    /// Не сработала авторизация через Apple
    case appleAuth
    /// Не сработала авторизация через facebook
    case facebookAuth
    /// Не валидный email
    case invalidEmail
    /// На валидный пароль
    case invalidPassword
    /// Аккаунт уже существует
    case isAlreadySignedUp
}

/// Для определения, по какой кнопке совершена попытка авторизации
enum RegisterAuthButtonType {
    case googleButton(presenterVC: UIViewController)
    case facebookButton(presenterVC: UIViewController)
    case appleButton(presenterVC: UIViewController)
    case submitButtonOrReturnButton(username: String, password: String, presenter: TransitionHandler)
}

protocol RegisterViewModelProtocol: AnyObject {
    var input: RegisterViewModelInput { get }
    var output: RegisterViewModelOutput { get }
}

protocol RegisterViewModelInput {
    func tryToLogin(sourceButtonType: RegisterAuthButtonType,
                    showActivityIndicator: @escaping () -> Void,
                    hideActivityIndicator: (() -> Void)?)
    func presentAgreementsViewController(presenter: TransitionHandler, type: AgreementsType)
    func checkTextfields(email: String?,
                         password: String?,
                         secondPassword: String?)
    // swiftlint:disable:next function_parameter_count
    func becomeFirstResponderOrClearOffTextfields(emailTextField: ASTextFieldNode,
                                                  passwordTestField: ASTextFieldNode,
                                                  passwordSecondTimeTextfield: ASTextFieldNode,
                                                  password: String,
                                                  secondPassword: String,
                                                  presenter: TransitionHandler)
    /// Включение/выключение кнопки submitButton
    func submitButtonChangeIsEnable()
    /// Прозрачность кнопки
    func submitButtonChangeAlpha()
    /// Выключение кнопки submitButton
    func disableSubmitButton()
    /// Поведение при клике на кнопку переключения состояния контроллера
    func changeViewControllerState()
    /// Смена текста кнопок в зависимости от состояния контроллера
    func changeButtonsTitle()
    /// Скрытие/отображение 3 текстфилда
    func secondTimeTextfieldIsHiddenToggle()
    /// Выключение лейбла, который про то, что пароли не совпадают
    func disableErrorLabel()
}

protocol RegisterViewModelOutput {
    // viewController
    var viewControllerState: BehaviorRelay<RegisterViewControllerState> { get }
    var viewControllerBackgroundColor: BehaviorRelay<UIColor> { get }
    // agreements
    var agreement: BehaviorRelay<(title:String, font: UIFont, color: UIColor)> { get }
    var politic: BehaviorRelay<(title:String, font: UIFont, color: UIColor)> { get }
    // submitButton
    /// Состояние активности submitButton
    var submitButtonState: BehaviorRelay<SubmitButtonState> { get }
    var submitButtonTextColor: BehaviorRelay<UIColor> { get }
    /// Для смены заголовка "авторизироваться" и "зарегистрироваться"
    var submitButtonTitle: BehaviorRelay<(title: String, font: UIFont)> { get }
    var submitButtonIsEnable: BehaviorRelay<Bool> { get }
    var submitButtonBackgroundColor: PublishRelay<UIColor> { get }
    // changeStateButton
    var changeStateButtonTitle: BehaviorRelay<(title: String, font: UIFont)> { get }
    var changeStateButtonColor: BehaviorRelay<UIColor> { get }
    // Текстфилды
    var textfieldsFont: BehaviorRelay<UIFont> { get }
    // nameTextfield
    var nameTextfieldText: PublishRelay<String> { get }
    var nameTextfieldPlaceholder: BehaviorRelay<(text: String, color: UIColor)> { get }
    // passwordTextfield
    var passwordTextfieldText: PublishRelay<String> { get }
    var passwordTextfieldPlaceholder: BehaviorRelay<(text: String, color: UIColor)> { get }
    // secondPasswordTextfield
    var secondPasswordTextfieldText: PublishRelay<String> { get }
    var secondPasswordTextfieldPlaceholder: BehaviorRelay<(text: String, color: UIColor)> { get }
    /// Скрытие/отобраение 3его текстфилда
    var secondPasswordTextfieldIsHidden: BehaviorRelay<Bool> { get }
    // errorPasswordText
    /// Шрифт, текст и цвет для errorPasswordLabel
    var errorLabelAttributedStringDataSource: BehaviorRelay<(text: String, // swiftlint:disable:this large_tuple
                                                             font: UIFont,
                                                             color: UIColor)> { get }
    /// Включение/выключение лейбла, который пишет, что пароли не совпадают при регистрации
    var errorLabelIsHidden: BehaviorRelay<Bool> { get }
    // AuthButtons
    var authButtonsBackgroundColor: BehaviorRelay<UIColor> { get }
    // orLabel
    /// Шрифт,текст и цвет для orLabel
    var orLabelAttributedStringDataSource: BehaviorRelay<(text: String,    // swiftlint:disable:this large_tuple
                                                          font: UIFont,
                                                          color: UIColor)> { get }
}

final class RegisterViewModel: RegisterViewModelProtocol {

    // MARK: Public properties
    var input: RegisterViewModelInput { return self }
    var output: RegisterViewModelOutput { return self }

    // Все описания пропертей сверху в протоколе output
    let viewControllerBackgroundColor: BehaviorRelay<UIColor>
    let viewControllerState = BehaviorRelay(value: RegisterViewControllerState.auth)
    // Agreements
    let agreement: BehaviorRelay<(title:String, font: UIFont, color: UIColor)>
    let politic: BehaviorRelay<(title:String, font: UIFont, color: UIColor)>
    // Submit button
    let submitButtonState = BehaviorRelay(value: SubmitButtonState.disable)
    let submitButtonTitle: BehaviorRelay<(title: String, font: UIFont)>
    let submitButtonIsEnable = BehaviorRelay<Bool>(value: false)
    let submitButtonBackgroundColor = PublishRelay<UIColor>()
    let submitButtonTextColor: BehaviorRelay<UIColor>
    // ChangeStateButton
    let changeStateButtonTitle: BehaviorRelay<(title: String, font: UIFont)>
    let changeStateButtonColor: BehaviorRelay<UIColor>
    // Textfields
    let textfieldsFont: BehaviorRelay<UIFont>
    // nameTextfield
    let nameTextfieldText = PublishRelay<String>()
    let nameTextfieldPlaceholder: BehaviorRelay<(text: String, color: UIColor)>
    // passwordTextfield
    let passwordTextfieldText = PublishRelay<String>()
    let passwordTextfieldPlaceholder: BehaviorRelay<(text: String, color: UIColor)>
    // secondPasswordTextfield
    let secondPasswordTextfieldText = PublishRelay<String>()
    let secondPasswordTextfieldPlaceholder: BehaviorRelay<(text: String, color: UIColor)>
    let secondPasswordTextfieldIsHidden = BehaviorRelay<Bool>(value: false)
    // errorPasswordsLabel
    // swiftlint:disable:next large_tuple
    let errorLabelAttributedStringDataSource: BehaviorRelay<(text: String,
                                                             font: UIFont,
                                                             color: UIColor)>
    let errorLabelIsHidden = BehaviorRelay<Bool>(value: true)
    // AuthButtons
    let authButtonsBackgroundColor: BehaviorRelay<UIColor>
    // orLabel
    // swiftlint:disable:next large_tuple
    let orLabelAttributedStringDataSource: BehaviorRelay<(text: String,
                                                          font: UIFont,
                                                          color: UIColor)>
    // MARK: Private properties
    private let disposeBag = DisposeBag()
    /// Координатор для флоу между контроллерами
    private let coordinator: CoordinatorProtocol
    /// Менеджер для регистрации/авторизации
    private let authFacade: AuthFacadeProtocol
    /// Для применения шрифтов
    private let fonts: (RegisterViewControllerFonts) -> UIFont
    /// Для установки всех текстов
    private let texts: (RegisterViewControllerTexts) -> String
    /// Для установки цветов
    private let palette: (RegisterViewControllerPalette) -> UIColor

    // MARK: Init
    // swiftlint:disable:next function_body_length
    init(coordinator: CoordinatorProtocol,
         authFacade: AuthFacadeProtocol,
         fonts: @escaping (RegisterViewControllerFonts) -> UIFont,
         texts: @escaping (RegisterViewControllerTexts) -> String,
         palette: @escaping (RegisterViewControllerPalette) -> UIColor) {
        self.coordinator = coordinator
        self.authFacade = authFacade
        self.fonts = fonts
        self.texts = texts
        self.palette = palette

        /// Стандартные значения для UI
        /// viewController
        viewControllerBackgroundColor = BehaviorRelay<UIColor>(value: palette(.viewControllerBackgroundColor))

        /// Agreements
        self.agreement = BehaviorRelay<(title: String,
                                        font: UIFont,
                                        color: UIColor)>(value: (title: texts(.termsOfUse),
                                                                 font: fonts(.agreements),
                                                                 color: palette(.agreementsTitleColor)))
        self.politic = BehaviorRelay<(title: String,
                                      font: UIFont,
                                      color: UIColor)>(value: (title: texts(.privacyPolicy),
                                                               font: fonts(.agreements),
                                                               color: palette(.agreementsTitleColor)))
        /// submitButton
        let submitButtonTitleText = texts(.authTextForButton)
        let submitButtonTitleFont = fonts(.submitButton)
        self.submitButtonTitle = BehaviorRelay<(title: String,
                                                font: UIFont)>(value: (
                                                    title: submitButtonTitleText,
                                                    font: submitButtonTitleFont))
        self.submitButtonTextColor = BehaviorRelay<UIColor>(value: palette(.submitButtonTextColor))
        /// changeStateButton
        let changeStateButtonText = texts(.sighUpTextForButton)
        let changeStateButtonFont = fonts(.changeStateButton)
        self.changeStateButtonTitle = BehaviorRelay<(title: String,
                                                     font: UIFont)>(value: (
                                                        title: changeStateButtonText,
                                                        font: changeStateButtonFont))
        self.changeStateButtonColor = BehaviorRelay<UIColor>(value: palette(.changeStateButtonColor))
        /// nameTextfield
        let nameTextFieldPlaceholderText = texts(.namePlaceholder)
        let placeholderColor = palette(.textfieldsPlaceholderColor)
        self.nameTextfieldPlaceholder = BehaviorRelay<(text: String,
                                                       color: UIColor)>(value: (text: nameTextFieldPlaceholderText,
                                                                                color: placeholderColor))

        /// passwordTextfield
        let passwordPlaceholderText = texts(.passwordPlaceholder)
        self.passwordTextfieldPlaceholder = BehaviorRelay<(text: String,
                                                           color: UIColor)>(value: (text: passwordPlaceholderText,
                                                                                    color: placeholderColor))

        /// secondPasswordTextfield
        let secondPassPlaceholderText = texts(.secondPasswordPlaceholder)
        self.secondPasswordTextfieldPlaceholder = BehaviorRelay<(text: String,
                                                                 color: UIColor)>(value: (text: secondPassPlaceholderText,
                                                                                          color: placeholderColor))

        /// Для всех текстфилдов
        self.textfieldsFont = BehaviorRelay<UIFont>(value: fonts(.registerTextfield))

        /// errorPasswordLabel
        let errorPasswordText = texts(.errorLabelPasswordsNotTheSame)
        self.errorLabelAttributedStringDataSource = BehaviorRelay<(text: String,
                                                                   font: UIFont,
                                                                   color: UIColor)>(value: (
                                                                    text: errorPasswordText,
                                                                    font: fonts(.registerErrorLabel),
                                                                    color: palette(.errorLabelTextColor)))
        /// AuthButtons
        self.authButtonsBackgroundColor = BehaviorRelay<UIColor>(value: palette(.authButtonBackground))
        /// orLabel
        let orLabelText = texts(.orLabelText)
        let orLabelFont = fonts(.registerOrLabel)
        let orLabelColor = palette(.orLabelTextColor)
        orLabelAttributedStringDataSource = BehaviorRelay<(text: String,
                                                           font: UIFont,
                                                           color: UIColor)>(value:
                                                                                (text: orLabelText,
                                                                                 font: orLabelFont,
                                                                                 color: orLabelColor))

        /// Подписка на изменения темы пользователя для автоматического обновления цвета
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(shouldUpdateColors),
                                               name: NSNotification.shouldUpdatePalette,
                                               object: nil)

    }

    // MARK: Private Methods
    private func showErrorLabelWithText(type: TextFieldType) {
        let oldFont = errorLabelAttributedStringDataSource.value.font
        let oldColor = errorLabelAttributedStringDataSource.value.color

        switch type {
        case .email:
            errorLabelAttributedStringDataSource.accept((text: texts(.errorLabelEmailInvalid),
                                                         font: oldFont,
                                                         color: oldColor))
        case .password:
            errorLabelAttributedStringDataSource.accept((text: texts(.errorLabelPasswordInvalid),
                                                         font: oldFont,
                                                         color: oldColor))
        }
        errorLabelIsHidden.accept(false)
    }

    private func generateAlertController(type: AlertControllerType) -> UIAlertController {

        let alertControllerTitle = texts(.alertControllerTitle)
        let alertController = UIAlertController(title: alertControllerTitle,
                                                message: "",
                                                preferredStyle: .alert)

        switch type {
        case .notCorrectLoginOrPassword:
            alertController.message = texts(.alertControllerAuthError)
        case .passwordsNotTheSame:
            alertController.message = texts(.alertControllerSignUpError)
        case .googleAuth:
            alertController.message = texts(.alertControllerGoogleAuthError)
        case .appleAuth:
            alertController.message = texts(.alertControllerAppleAuthError)
        case .facebookAuth:
            alertController.message = texts(.alertControllerFacebookAuthError)
        case .invalidEmail:
            alertController.message = texts(.alertControllerInvalidEmail)
        case .isAlreadySignedUp:
            alertController.message = texts(.alertControllerIsAlreadySignUp)
        case .invalidPassword:
            alertController.message = texts(.alertControllerInvalidPassword)
        }

        let okActionText = texts(.alertControllerOKAction)
        let okAction = UIAlertAction(title: okActionText, style: .default) { _ in
            alertController.dismiss(animated: true)
        }

        alertController.addAction(okAction)
        return alertController
    }

    // MARK: OBJC private methods
    /// Обновление ui после изменения темы телефона
    @objc private func shouldUpdateColors() {
        viewControllerBackgroundColor.accept(palette(.viewControllerBackgroundColor))
        submitButtonTextColor.accept(palette(.submitButtonTextColor))
        switch submitButtonIsEnable.value {
        case true:
            submitButtonBackgroundColor.accept(palette(.submitButtonActiveTintColor))
        case false:
            submitButtonBackgroundColor.accept(palette(.submitButtonDisableTintColor))
        }
        changeStateButtonColor.accept(palette(.changeStateButtonColor))
        authButtonsBackgroundColor.accept(palette(.authButtonBackground))

        let orLabelText = orLabelAttributedStringDataSource.value.text
        let orLabelFont = orLabelAttributedStringDataSource.value.font
        orLabelAttributedStringDataSource.accept((text: orLabelText,
                                                  font: orLabelFont,
                                                  color: palette(.orLabelTextColor)))

        let errorLabelText = errorLabelAttributedStringDataSource.value.text
        let errorLabelFont = errorLabelAttributedStringDataSource.value.font
        errorLabelAttributedStringDataSource.accept((text: errorLabelText,
                                                     font: errorLabelFont,
                                                     color: palette(.errorLabelTextColor)))
    }
}

// MARK: - extension + RegisterViewModelOutput  -
extension RegisterViewModel: RegisterViewModelOutput {

}

// MARK: - extension + RegisterViewModelInput  -
extension RegisterViewModel: RegisterViewModelInput {

    // MARK: Public Methods
    // swiftlint:disable:next function_body_length
    func tryToLogin(sourceButtonType: RegisterAuthButtonType, // swiftlint:disable:this cyclomatic_complexity
                    showActivityIndicator: @escaping () -> Void,
                    hideActivityIndicator: (() -> Void)? = nil) {

        switch viewControllerState.value {
        case .auth:
            switch sourceButtonType {
            case .googleButton(let presenter):
                guard let hideActivityIndicator = hideActivityIndicator else { return }
                authFacade.signInWithGoogle(presenterVC: presenter,
                                             showActivityIndicator: showActivityIndicator,
                                             hideActivityIndicator: hideActivityIndicator)
                .subscribe(onSuccess: { [coordinator] chatUser in
                    guard let chatUser = chatUser else { return }
                    coordinator.presentChatsListNavigationController(withChatUser: chatUser)
                }, onFailure: { [generateAlertController] _ in
                    let alertController = generateAlertController(.googleAuth)
                    presenter.present(alertController, animated: true)
                })
                .disposed(by: disposeBag)
            case .facebookButton(let presenter):
                guard let hideActivityIndicator = hideActivityIndicator else { return }
                authFacade.signInWithFacebook(presenterVC: presenter,
                                               showActivityIndicator: showActivityIndicator,
                                               hideActivityIndicator: hideActivityIndicator)
                .subscribe(onSuccess: { [coordinator] chatUser in
                    guard let chatUser = chatUser else { return }
                    coordinator.presentChatsListNavigationController(withChatUser: chatUser)
                }, onFailure: { [generateAlertController] _ in
                    let alertController = generateAlertController(.facebookAuth)
                    presenter.present(alertController, animated: true)
                })
                .disposed(by: disposeBag)
            case .appleButton(let presenter):
                guard let hideActivityIndicator = hideActivityIndicator else { return }
                authFacade.signInWithApple(showActivityIndicator: showActivityIndicator,
                                            hideActivityIndicator: hideActivityIndicator)
                .subscribe { [coordinator] chatUser in
                    guard let chatUser = chatUser else { return }
                    coordinator.presentChatsListNavigationController(withChatUser: chatUser)
                } onFailure: { [generateAlertController] _ in
                    let alertController = generateAlertController(.appleAuth)
                    presenter.presentViewController(viewController: alertController,
                                                    animated: true,
                                                    completion: nil)
                }
                .disposed(by: disposeBag)
            case .submitButtonOrReturnButton(let username, let password, let presenter):
                guard let hideActivityIndicator = hideActivityIndicator else { return }
                authFacade.signIn(withEmail: username,
                                   password: password,
                                   hideActivityIndicator: hideActivityIndicator)
                .subscribe(onSuccess: { [coordinator] chatUser in
                    guard let chatUser = chatUser else { return }
                    coordinator.presentChatsListNavigationController(withChatUser: chatUser)
                }, onFailure: { [generateAlertController] _ in
                    let alertController = generateAlertController(.notCorrectLoginOrPassword)
                    presenter.presentViewController(viewController: alertController,
                                                    animated: true,
                                                    completion: nil)
                })
                .disposed(by: disposeBag)
            }

        case .register:
            switch sourceButtonType {
            case .submitButtonOrReturnButton(let username, let password, let presenter):
                guard let hideActivityIndicator = hideActivityIndicator else { return }
                authFacade.createUser(withEmail: username,
                                      password: password,
                                      hideActivityIndicator: hideActivityIndicator)
                .subscribe { [coordinator] chatUser in
                    guard let chatUser = chatUser else { return }
                    coordinator.presentProfileViewController(chatUser: chatUser, presenter: presenter)
                } onFailure: { [weak self, generateAlertController] error in
                    if (error as NSError).code == 17007 {   // Уже существует аккаунт
                        let allertController = generateAlertController(.isAlreadySignedUp)
                        presenter.presentViewController(viewController: allertController,
                                                        animated: true,
                                                        completion: nil)
                        self?.nameTextfieldText.accept("")
                        self?.passwordTextfieldText.accept("")
                        self?.secondPasswordTextfieldText.accept("")
                    }
                }
                .disposed(by: disposeBag)
            default: break
            }
        }
    }

    func presentAgreementsViewController(presenter: TransitionHandler, type: AgreementsType) {
        coordinator.presentAgreementsViewController(presenter: presenter, type: type)
    }

    // swiftlint:disable:next cyclomatic_complexity
    func checkTextfields(email: String?,    // swiftlint:disable:this function_body_length
                         password: String?,
                         secondPassword: String?) {
        if viewControllerState.value == .register {
            // Включаем/выключаем кнопку исходя из содержания всех филдов для состояния "регистрация"
            if email != "",
               password != "",
               secondPassword != "",
               password == secondPassword,
               let email = email,
               let password = password,
               Utils.validate(email: email),
               Utils.validate(password: password) {
                submitButtonState.accept(.enable)
            } else {
                submitButtonState.accept(.disable)
            }

            // Логика по выводу errorLabel для отображения ошибки
            if password != secondPassword && (password != "" && secondPassword != "") {

                let oldFont = errorLabelAttributedStringDataSource.value.font
                let oldColor = errorLabelAttributedStringDataSource.value.color

                // swiftlint:disable:next line_length
                errorLabelAttributedStringDataSource.accept((text: texts(.errorLabelPasswordsNotTheSame),
                                                             font: oldFont,
                                                             color: oldColor))
                errorLabelIsHidden.accept(false)
                return
            } else if password == secondPassword && (password != "" && secondPassword != "") {
                if let email = email, email != "" {
                    if !Utils.validate(email: email) {
                        showErrorLabelWithText(type: .email)
                        return
                    }
                }
            }

            if let email = email, email != "" {
                if !Utils.validate(email: email) {
                    showErrorLabelWithText(type: .email)
                    return
                }
            }

            if password != "" {
                if !Utils.validate(password: password ?? "") {
                    showErrorLabelWithText(type: .password)
                    return
                }
            }

            if secondPassword != "" {
                if !Utils.validate(password: secondPassword ?? "") {
                    showErrorLabelWithText(type: .password)
                    return
                }
            }

            errorLabelIsHidden.accept(true)
        } else {
            // Включаем/выключаем кнопку исходя из содержания всех филдов для состояния "авторизация"
            (email != "" && password != "")
            ? submitButtonState.accept(.enable)
            : submitButtonState.accept(.disable)
        }
    }

    // swiftlint:disable:next function_parameter_count
    func becomeFirstResponderOrClearOffTextfields(emailTextField: ASTextFieldNode,
                                                  passwordTestField: ASTextFieldNode,
                                                  passwordSecondTimeTextfield: ASTextFieldNode,
                                                  password: String,
                                                  secondPassword: String,
                                                  presenter: TransitionHandler) {

        if emailTextField.text != ""
            && passwordTestField.text != ""
            && passwordSecondTimeTextfield.text != "" {

            errorLabelIsHidden.accept(true)

            if !Utils.validate(email: emailTextField.text as String) {
                let alertController = generateAlertController(type: .invalidEmail)
                emailTextField.textField.becomeFirstResponder()
                presenter.presentViewController(viewController: alertController,
                                                animated: true,
                                                completion: nil)
                return
            }

            if password != secondPassword {
                let alertController = generateAlertController(type: .passwordsNotTheSame)
                cleanPasswordsTextfields()
                passwordTestField.textField.becomeFirstResponder()
                presenter.presentViewController(viewController: alertController,
                                                animated: true,
                                                completion: nil)
                return
            }

            if !Utils.validate(password: password) || !Utils.validate(password: secondPassword) {
                let alertController = generateAlertController(type: .invalidPassword)
                cleanPasswordsTextfields()
                passwordTestField.textField.becomeFirstResponder()
                presenter.presentViewController(viewController: alertController,
                                                animated: true,
                                                completion: nil)
                return
            }

        } else {
            // Здесь решается, какой из филдов станет респондером (один из пустых)
            let textfields = [emailTextField,
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
            submitButtonBackgroundColor.accept(palette(.submitButtonActiveTintColor))
        case .disable:
            submitButtonBackgroundColor.accept(palette(.submitButtonDisableTintColor))
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
        errorLabelIsHidden.accept(true)
    }

    func cleanPasswordsTextfields() {
        passwordTextfieldText.accept("")
        secondPasswordTextfieldText.accept("")
    }
} // swiftlint:disable:this file_length
