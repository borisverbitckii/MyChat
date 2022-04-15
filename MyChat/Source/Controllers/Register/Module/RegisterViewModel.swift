//
//  RegisterViewModel.swift
//  MyChat
//
//  Created by Борис on 14.02.2022.
//

import UIKit
import RxRelay
import RxSwift
import AsyncDisplayKit
import AuthenticationServices
import CryptoKit
import Services
import Models

enum RegisterViewControllerState {
    case auth, register  // состояния контроллера, чтобы отображать вид авторизации или регистрации
}

enum SubmitButtonState {
    case enable, disable // для включения выключения submitButton
}

enum TextFieldType {
    case email, password
}

enum AlertControllerType {
    case notCorrectLoginOrPassword  // Для того, чтобы вывести "вы ввели не правильный логин и пароль"
    case passwordsNotTheSame        // Для того, чтобы вывести "пароли не совпадают"
    case googleAuth                 // Не сработала авторизация через google
    case appleAuth                  // Не сработала авторизация через Apple
    case facebookAuth               // Не сработала авторизация через facebook
    case invalidEmail               // Не валидный email
    case invalidPassword            // На валидный пароль
    case isAlreadySignUp            // Аккаунт уже существует
}

// Для определения, по какой кнопке совершена попытка авторизации
enum RegisterAuthButtonType {
    case googleButton, facebookButton, appleButton, submitButtonOrReturnButton
}

protocol RegisterViewModelProtocol: AnyObject {
    var input: RegisterViewModelInput { get }
    var output: RegisterViewModelOutput { get }
}

protocol RegisterViewModelInput {
    func startAppleAuthFlow(authorizationControllerDelegate: RegisterViewController,
                            presentationContextProvider: RegisterViewController)
    func authWithAppleInFirebase(idTokenForAuth: String)
    func showAppleAuthError(presenter: TransitionHandler)
    func presentTabBarController(withEmail username: String?,
                                 password: String?,
                                 sourceButtonType: RegisterAuthButtonType,
                                 presenter: UIViewController?)
    func checkTextfields(email: String?,
                         password: String?,
                         secondPassword: String?)
    func cleanTextfields()
    // swiftlint:disable:next function_parameter_count
    func becomeFirstResponderOrClearOffTextfields(emailTextField: ASTextFieldNode,
                                                  passwordTestField: ASTextFieldNode,
                                                  passwordSecondTimeTextfield: ASTextFieldNode,
                                                  password: String,
                                                  secondPassword: String,
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
    var submitButtonState: BehaviorRelay<SubmitButtonState> { get }             // Активна или не активна
    var submitButtonTitle: BehaviorRelay<(title: String, font: UIFont)> { get }
    // Для смены заголовка "авторизироваться" и "зарегистрироваться"
    var submitButtonIsEnable: BehaviorRelay<Bool> { get }                       // Включение/выключение кнопки
    var submitButtonColor: PublishRelay<UIColor> { get }                        // Прозрачность кнопки
    // changeStateButton
    var changeStateButtonTitle: BehaviorRelay<(title: String, font: UIFont)> { get } // Заголовок для кнопки
    // Текстфилды
    var textfieldsFont: BehaviorRelay<UIFont> { get }                           // Один шрифт на все текстфилды
    // nameTextfield
    var nameTextfieldText: PublishRelay<String> { get }
    var nameTextfieldPlaceholder: BehaviorRelay<String> { get }
    // passwordTextfield
    var passwordTextfieldText: PublishRelay<String> { get }
    var passwordTextfieldPlaceholder: BehaviorRelay<String> { get }
    // secondPasswordTextfield
    var secondPasswordTextfieldText: PublishRelay<String> { get }
    var secondPasswordTextfieldPlaceholder: BehaviorRelay<String> { get }
    var secondPasswordTextfieldIsHidden: BehaviorRelay<Bool> { get }            // Скрытие/отобраение 3его текстфилда
    // errorPasswordText
    // swiftlint:disable:next large_tuple
    var errorLabelTextFontColor: BehaviorRelay<(text: String,
                                                font: UIFont,
                                                color: UIColor)> { get }        // шрифт и текст для errorPasswordLabel
    // Заголовок для лейбла, который пишет, что пароли не совпадают при регистрации
    var errorLabelIsHidden: BehaviorRelay<Bool> { get }
    // Включение/выключение лейбла, который пишет, что пароли не совпадают при регистрации
    // orLabel
    // swiftlint:disable:next large_tuple
    var orLabel: BehaviorRelay<(text: String,
                                font: UIFont,
                                color: UIColor)> { get }                        // Шрифт,текст и цвет для orLabel
}

final class RegisterViewModel: RegisterViewModelProtocol {

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
    // swiftlint:disable:next large_tuple
    var errorLabelTextFontColor: BehaviorRelay<(text: String,
                                                font: UIFont,
                                                color: UIColor)>
    var errorLabelIsHidden = BehaviorRelay<Bool>(value: true)
    // orLabel
    // swiftlint:disable:next large_tuple
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

    private var currentNonce: String?                               // Для авторизации и шифрования Apple
    private var appleChatUser: ChatUser?                            // Для авторизации в apple

    // MARK: Init
    // swiftlint:disable:next function_body_length
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
        let errorPasswordText = texts(.errorLabelPasswordsNotTheSame)
        errorLabelTextFontColor = BehaviorRelay<(text: String,
                                                 font: UIFont,
                                                 color: UIColor)>(value: (
                                                    text: errorPasswordText,
                                                    font: fonts(.registerErrorLabel),
                                                    color: palette(.errorLabelTextColor)))

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

    // MARK: Private Methods
    private func showErrorLabelWithText(type: TextFieldType) {
        let oldFont = errorLabelTextFontColor.value.font
        let oldColor = errorLabelTextFontColor.value.color

        switch type {
        case .email:
            errorLabelTextFontColor.accept((text: texts(.errorLabelEmailInvalid),
                                            font: oldFont,
                                            color: oldColor))
        case .password:
            errorLabelTextFontColor.accept((text: texts(.errorLabelPasswordInvalid),
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
        case .isAlreadySignUp:
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
}

// MARK: - extension + RegisterViewModelOutput  -
extension RegisterViewModel: RegisterViewModelOutput {

}

// MARK: - extension + RegisterViewModelInput  -
extension RegisterViewModel: RegisterViewModelInput {

    // MARK: Public Methods
    func startAppleAuthFlow(authorizationControllerDelegate: RegisterViewController,
                            presentationContextProvider: RegisterViewController) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email, .fullName]
        currentNonce = randomNonceString(length: 32)
        guard let nonce = currentNonce else { return }
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = authorizationControllerDelegate
        authorizationController.presentationContextProvider = presentationContextProvider
        authorizationController.performRequests()
    }

    func authWithAppleInFirebase(idTokenForAuth: String) {
        guard let nonce = currentNonce else {
            assertionFailure() // TODO: Залогировать
            return
        }

        authManager.sighInWithApple(idTokenForAuth: idTokenForAuth,
                                    nonce: nonce)
        .subscribe { [weak self] chatUser in
            self?.appleChatUser = chatUser
            self?.presentTabBarController(withEmail: nil,
                                          password: nil,
                                          sourceButtonType: .appleButton,
                                          presenter: nil)
        } onFailure: { error in
            print(error) // TODO: Залогировать
        }
        .disposed(by: disposeBag)

    }

    func showAppleAuthError(presenter: TransitionHandler) {
        let alertController = generateAlertController(type: .appleAuth)
        presenter.presentViewController(viewController: alertController,
                                        animated: true,
                                        completion: nil)
    }

    // swiftlint:disable:next function_body_length
    func presentTabBarController(withEmail email: String?, // swiftlint:disable:this cyclomatic_complexity
                                 password: String?,
                                 sourceButtonType: RegisterAuthButtonType,
                                 presenter: UIViewController?) {

        switch viewControllerState.value {
        case .auth:
            switch sourceButtonType {
            case .googleButton:
                if let presenter = presenter {
                    authManager.signInWithGoogle(presenterVC: presenter)
                        .subscribe(onSuccess: { [coordinator] chatUser in
                            guard let chatUser = chatUser else { return }
                            coordinator.presentTabBarViewController(withChatUser: chatUser)
                        }, onFailure: { [generateAlertController] _ in // TODO: Залогировать ошибку
                            let alertController = generateAlertController(.googleAuth)
                            presenter.present(alertController, animated: true)
                        })
                        .disposed(by: disposeBag)
                }
            case .facebookButton:
                if let presenter = presenter {
                    authManager.signInWithFacebook(presenterVC: presenter)
                        .subscribe(onSuccess: { [coordinator] chatUser in
                            guard let chatUser = chatUser else { return }
                            coordinator.presentTabBarViewController(withChatUser: chatUser)
                        }, onFailure: { [generateAlertController] _ in // TODO: Залогировать ошибку
                            let alertController = generateAlertController(.facebookAuth)
                            presenter.present(alertController, animated: true)
                        })
                        .disposed(by: disposeBag)
                }

            case .appleButton:
                guard let chatUser = appleChatUser else {
                    assertionFailure(AssertionErrorMessages.appleAuthError.assertionErrorMessage)
                    return
                }
                coordinator.presentTabBarViewController(withChatUser: chatUser)

            case .submitButtonOrReturnButton:
                guard let username = email,
                      let password = password,
                      let presenter = presenter else { return }

                authManager.signIn(withEmail: username, password: password)
                    .subscribe(onSuccess: { [coordinator] chatUser in
                        guard let chatUser = chatUser else { return }
                        coordinator.presentTabBarViewController(withChatUser: chatUser)
                    }, onFailure: { [generateAlertController] _ in // TODO: Залогировать ошибку
                        let alertController = generateAlertController(.notCorrectLoginOrPassword)
                        presenter.present(alertController, animated: true)
                    })
                    .disposed(by: disposeBag)
            }

        case .register:
            guard let username = email, let password = password else { return }
            authManager.createUser(withEmail: username, password: password)
                .subscribe { [coordinator] chatUser in
                    guard let chatUser = chatUser else { return }
                    coordinator.presentTabBarViewController(withChatUser: chatUser)
                } onFailure: { [weak self, generateAlertController] error in
                    if (error as NSError).code == 17007 { // Уже существует аккаунт
                        let allertController = generateAlertController(.isAlreadySignUp)
                        presenter?.presentViewController(viewController: allertController,
                                                         animated: true,
                                                         completion: nil)
                        self?.nameTextfieldText.accept("")
                        self?.passwordTextfieldText.accept("")
                        self?.secondPasswordTextfieldText.accept("")
                    }
                    print(error) // TODO: Обработать ошибки и залогировать
                }
                .disposed(by: disposeBag)
        }
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

                let oldFont = errorLabelTextFontColor.value.font
                let oldColor = errorLabelTextFontColor.value.color

                // swiftlint:disable:next line_length
                errorLabelTextFontColor.accept((text: texts(.errorLabelPasswordsNotTheSame), // TODO: Внести в source Text
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

    func cleanTextfields() {
        nameTextfieldText.accept("")
        passwordTextfieldText.accept("")
        secondPasswordTextfieldText.accept("")
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
        errorLabelIsHidden.accept(true)
    }

    func cleanPasswordsTextfields() {
        passwordTextfieldText.accept("")
        secondPasswordTextfieldText.accept("")
    }
}

// Для авторизации Apple
private extension RegisterViewModel {

    // MARK: Private methods
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
} // swiftlint:disable:this file_length
