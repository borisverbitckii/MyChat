//
//  RegisterViewController.swift
//  MyChat
//
//  Created by Борис on 14.02.2022.
//

import RxSwift
import AsyncDisplayKit
import UIKit
import UI
import AuthenticationServices

// swiftlint:disable:next type_body_length
final class RegisterViewController: ASDKViewController<ASDisplayNode> {

    // MARK: Private properties
    /// Вынесенные UI элементы
    private let uiElements: RegisterUI
    /// Все локальные константы
    private let constants: RegisterConstants
    private let viewModel: RegisterViewModelProtocol
    private let bag = DisposeBag()

    /// Флаг, чтобы убрать глюки появления/исчезновения клавиатуры
    private var isKeyboardShown = false
    private var keyboardHeight: CGFloat = 0
    private var isPhoneWithHomeButton: Bool {
        UIApplication.shared.windows[0].safeAreaInsets.bottom  == 0
    }

    /// Переменные, чтобы исправить баг с прыгающим текстом в текстфилде, когда включен isSecureTextEntry
    private var passwordText = "" {
        didSet {
            textfieldTextDidChange()
        }
    }
    private var secondPasswordText = "" {
        didSet {
            textfieldTextDidChange()
        }
    }

    // MARK: Init
    init(uiElements: RegisterUI,
         registerViewModel: RegisterViewModelProtocol,
         constants: RegisterConstants) {
        self.uiElements = uiElements
        self.constants = constants
        self.viewModel = registerViewModel
        super.init(node: ASDisplayNode())
        self.node.automaticallyManagesSubnodes = true
        self.node.layoutSpecBlock = layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override methods -
    override func viewDidLoad() {
        super.viewDidLoad()
        node.backgroundColor = .white
        bindUIElements()
        subscribeToObservables()
        addTargetsForButtons()
        addTargetsForTextfields()
        setupDelegates()
        addKeyboardObservers()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Скрываем клавиатуру при клику на любую область
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }

    // MARK: - Private methods -
    // swiftlint:disable:next function_body_length
    private func layout() -> ASLayoutSpecBlock? {
        return { [weak self] _, _ in
            guard let self = self else { return ASLayoutSpec() }

            // orLabel
            let centerOrSpec = ASCenterLayoutSpec(centeringOptions: .XY,
                                                  sizingOptions: [],
                                                  child: self.uiElements.orLabel)

            // Вертикальный стэк для филдов + orLabel + кнопки авторизации
            var textfieldsChildren = [ASLayoutElement]()

            switch self.viewModel.output.viewControllerState.value {
            case .auth:
                textfieldsChildren = [self.uiElements.nameTextField,
                                      self.uiElements.passwordTestField,
                                      centerOrSpec,
                                      self.uiElements.authButtons]

            case .register:
                textfieldsChildren = [self.uiElements.nameTextField,
                                      self.uiElements.passwordTestField,
                                      self.uiElements.passwordSecondTimeTextfield]
            }

            let vStack = ASStackLayoutSpec()
            vStack.direction = .vertical
            vStack.spacing = self.constants.textfieldsStackSpacing
            vStack.horizontalAlignment = .middle
            vStack.children = textfieldsChildren

            for node in textfieldsChildren {
                if let textfield = node as? TextFieldWithBottomBorderNode {
                    textfield.textfield.style.preferredSize = self.constants.stackElementSize
                    continue
                }

                node.style.preferredSize = self.constants.stackElementSize
            }

            let vStackCenterSpec = ASCenterLayoutSpec(centeringOptions: .XY,
                                                      sizingOptions: [], child: vStack)

            // Кнопки + errorLabel
            let labelCenterLayoutSpec = ASCenterLayoutSpec(centeringOptions: .XY,
                                                           sizingOptions: [],
                                                           child: self.uiElements.errorLabel)

            let buttonsChildren: [ASLayoutElement] = [labelCenterLayoutSpec,
                                                      self.uiElements.submitButton,
                                                      self.uiElements.changeStateButton]

            let buttonsVerticalStack = ASStackLayoutSpec()
            buttonsVerticalStack.direction = .vertical
            buttonsVerticalStack.horizontalAlignment = .middle
            buttonsVerticalStack.children = buttonsChildren

            buttonsChildren.forEach { $0.style.preferredSize = self.constants.buttonsSize }

            var bottomInset = self.constants.bottomInsetForPhonesWithoutHomeButton

            // Отступ для айфонов без home кнопки
            if self.isPhoneWithHomeButton {
                bottomInset = self.constants.bottomInsetForPhonesWithHomeButton
            }

            var buttonsInsets: UIEdgeInsets?
            var vStackTextfieldsInsets = UIEdgeInsets()

            // Обработка появления клавиатуры
            if self.isKeyboardShown {
                buttonsInsets = UIEdgeInsets(top: .infinity,
                                             left: .infinity,
                                             bottom: self.keyboardHeight + bottomInset ,
                                             right: .infinity)

                if self.isPhoneWithHomeButton {
                    vStackTextfieldsInsets = UIEdgeInsets(top: .infinity,
                                                          left: .infinity,
                                                          bottom: self.constants
                        .textfieldsStackTopInsetForPhonesWithHomeButton,
                                                          right: .infinity)
                } else {
                    vStackTextfieldsInsets = UIEdgeInsets(top: .infinity,
                                                          left: .infinity,
                                                          bottom: self.constants
                        .textfieldsStackTopInsetForPhonesWithoutHomeButton,
                                                          right: .infinity)
                }
            } else {
                buttonsInsets = UIEdgeInsets(top: .infinity,
                                             left: .infinity,
                                             bottom: bottomInset,
                                             right: .infinity)
            }
            guard let buttonsInsets = buttonsInsets else { return ASLayoutSpec() }

            let insetsButtonsSpec = ASInsetLayoutSpec(insets: buttonsInsets, child: buttonsVerticalStack)
            let vStackWithInsetsTextfieldsSpec = ASInsetLayoutSpec(insets: vStackTextfieldsInsets,
                                                                   child: vStackCenterSpec)
            let overlayButtonSpec = ASOverlayLayoutSpec(child: vStackWithInsetsTextfieldsSpec,
                                                        overlay: insetsButtonsSpec)

            return overlayButtonSpec
        }
    }

    /// Бинд всех данных из вью модели в ui элементы
    private func bindUIElements() { // swiftlint:disable:this function_body_length

        // viewController
        viewModel.output.viewControllerBackgroundColor
            .distinctUntilChanged()
            .subscribe { [weak node, constants] event in
                UIView.animate(withDuration: constants.animationDurationForColors) {
                    node?.backgroundColor = event.element
                }
            }
            .disposed(by: bag)

        // submitButton
        viewModel.output.submitButtonTitle
            .subscribe { [weak uiElements, constants] event in
                guard let button = uiElements?.submitButton.view else { return }
                UIView.transition(with: button,
                                  duration: constants.animationDurationForErrorLabel,
                                  options: .transitionCrossDissolve) {

                    uiElements?.submitButton.setTitle(event.element?.title ?? "",
                                                      with: event.element?.font,
                                                      with: nil,
                                                      for: .normal)
                }
            }
            .disposed(by: bag)

        viewModel.output.submitButtonIsEnable // делает кнопку активной/не активной в таргете текстфилдов
            .distinctUntilChanged()
            .subscribe { [weak uiElements] event in
                uiElements?.submitButton.isEnabled = event.element ?? false
            }
            .disposed(by: bag)

        viewModel.output.submitButtonBackgroundColor
            .distinctUntilChanged()
            .subscribe { [weak uiElements, constants] event in
                UIView.animate(withDuration: constants.animationDurationForColors) {
                    uiElements?.submitButton.backgroundColor = event.element
                }
            }
            .disposed(by: bag)

        viewModel.output.submitButtonTextColor
            .distinctUntilChanged()
            .subscribe { [weak uiElements, constants] event in
                UIView.animate(withDuration: constants.animationDurationForColors) {
                    uiElements?.submitButton.tintColor = event.element
                }
            }
            .disposed(by: bag)

        // changeStateButton
        viewModel.output.changeStateButtonTitle
            .subscribe { [weak uiElements, constants] event in

                guard let button = uiElements?.changeStateButton.view else { return }
                UIView.transition(with: button,
                                  duration: constants.animationDurationForErrorLabel,
                                  options: .transitionCrossDissolve) {
                    uiElements?.changeStateButton.setTitle(event.element?.title ?? "",
                                                           with: event.element?.font,
                                                           with: nil,
                                                           for: .normal)
                }
            }
            .disposed(by: bag)

        viewModel.output.changeStateButtonColor
            .distinctUntilChanged()
            .subscribe { [weak uiElements, constants] event in
                UIView.animate(withDuration: constants.animationDurationForColors) {
                    uiElements?.changeStateButton.tintColor = event.element
                }
            }
            .disposed(by: bag)

        // Все текстфилды
        viewModel.output.textfieldsFont
            .distinctUntilChanged()
            .subscribe { [weak uiElements] event in
                [ uiElements?.nameTextField,
                  uiElements?.passwordTestField,
                  uiElements?.passwordSecondTimeTextfield
                ].forEach { $0?.textfield.font = event.element }
            }
            .disposed(by: bag)

        viewModel.output.textfieldsBackgroundColor
            .distinctUntilChanged()
            .subscribe { [weak uiElements, constants] event in
                UIView.animate(withDuration: constants.animationDurationForColors) {
                    [ uiElements?.nameTextField,
                      uiElements?.passwordTestField,
                      uiElements?.passwordSecondTimeTextfield
                    ].forEach { $0?.textfield.backgroundColor = event.element }
                }
            }
            .disposed(by: bag)

        // nameTextfield
        viewModel.output.nameTextfieldText
            .distinctUntilChanged()
            .subscribe { [weak uiElements] event in
                guard let string = event.element else { return }
                uiElements?.nameTextField.textfield.text = string
            }
            .disposed(by: bag)

        viewModel.output.nameTextfieldPlaceholder
            .distinctUntilChanged()
            .subscribe { [weak uiElements] event in
                uiElements?.nameTextField.textfield.placeholder = event.element
            }.disposed(by: bag)

        // passwordTextfield
        viewModel.output.passwordTextfieldText
            .distinctUntilChanged()
            .subscribe { [weak self] event in
                guard let string = event.element else { return }
                self?.uiElements.passwordTestField.textfield.text = string
                self?.passwordText = ""
            }
            .disposed(by: bag)

        viewModel.output.passwordTextfieldPlaceholder
            .distinctUntilChanged()
            .subscribe { [weak uiElements] event in
                uiElements?.passwordTestField.textfield.placeholder = event.element
            }
            .disposed(by: bag)

        // secondPasswordTextfieldTex
        viewModel.output.secondPasswordTextfieldText
            .distinctUntilChanged()
            .subscribe { [weak self] event in
                guard let string = event.element else { return }
                self?.uiElements.passwordSecondTimeTextfield.textfield.text = string
                self?.secondPasswordText = ""
            }
            .disposed(by: bag)

        viewModel.output.secondPasswordTextfieldPlaceholder
            .distinctUntilChanged()
            .subscribe { [weak uiElements] event in
                uiElements?.passwordSecondTimeTextfield.textfield.placeholder = event.element
            }
            .disposed(by: bag)

        viewModel.output.secondPasswordTextfieldIsHidden
            .distinctUntilChanged()
            .subscribe { [weak uiElements, constants] event in
                if event.element == true {
                    UIView.animate(withDuration: constants.animationDurationForColors) {
                        // swiftlint:disable:next line_length
                        uiElements?.passwordSecondTimeTextfield.alpha = constants.passwordSecondTimeTextfieldAlphaDisable
                    } completion: { _ in
                        uiElements?.passwordSecondTimeTextfield.isHidden = event.element ?? false
                    }
                } else {
                    UIView.animate(withDuration: constants.animationDurationForColors) {
                        uiElements?.passwordSecondTimeTextfield.isHidden = event.element ?? false
                        uiElements?.passwordSecondTimeTextfield.alpha = constants.passwordSecondTimeTextfieldAlphaEnable
                    }
                }
            }
            .disposed(by: bag)

        // errorLabelText
        viewModel.output.errorLabelAttributedStringDataSource
            .subscribe { [weak uiElements] event in
                guard let text = event.element?.text,
                      let font = event.element?.font,
                      let color = event.element?.color else { return }
                let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: color]
                let attributedStringText = NSAttributedString(string: text,
                                                              attributes: attributes)
                uiElements?.errorLabel.attributedText = attributedStringText
            }
            .disposed(by: bag)

        viewModel.output.errorLabelIsHidden
            .distinctUntilChanged()
            .subscribe { [weak uiElements, constants] event in
                if event.element == true {
                    UIView.animate(withDuration: constants.animationDurationForColors) {
                        uiElements?.errorLabel.alpha = constants.passwordSecondTimeTextfieldAlphaDisable
                    } completion: { _ in
                        uiElements?.errorLabel.isHidden = event.element ?? true
                    }
                } else {
                    UIView.animate(withDuration: constants.animationDurationForColors) {
                        uiElements?.errorLabel.isHidden = event.element ?? false
                        uiElements?.errorLabel.alpha = constants.passwordSecondTimeTextfieldAlphaEnable
                    }
                }
            }
            .disposed(by: bag)
        // authButtons
        viewModel.output.authButtonsBackgroundColor
            .distinctUntilChanged()
            .subscribe { [weak uiElements, constants] event in
                guard let color = event.element else { return }
                UIView.animate(withDuration: constants.animationDurationForColors) {
                    uiElements?.authButtons.configureBackground(withColor: color)
                }
            }
            .disposed(by: bag)

        // orLabel
        viewModel.output.orLabelAttributedStringDataSource
            .subscribe { [weak uiElements] event in
                guard let text = event.element?.text,
                      let font = event.element?.font,
                      let color = event.element?.color else { return }
                let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: color]
                let attributedStringText = NSAttributedString(string: text,
                                                              attributes: attributes)
                uiElements?.orLabel.attributedText = attributedStringText
            }
            .disposed(by: bag)
    }

    private func subscribeToObservables() {

        // Подписка на все обсервабл

        /* Изменение состояния registerViewController
         Всего 2 состояния для контроллера: авторизация и регистрация
         - В зависимости от состояния мы либо показываем текст филд для дублирования пароля, или нет
         - Убираем/добавляем авторизацию через сервисы
         - Меняем текст кнопок submit и changeState
         - Выключаем лейбл, который говорит о ошибках с полями регистрации
         - ResignFirstResponder для текстфилдов при переключении состояния
         */

        viewModel.output.viewControllerState
            .subscribe { [weak viewModel, weak uiElements] _ in
                viewModel?.input.secondTimeTextfieldIsHiddenToggle()
                viewModel?.input.changeButtonsTitle()
                viewModel?.input.disableErrorLabel()

                [uiElements?.nameTextField,
                 uiElements?.passwordTestField,
                 uiElements?.passwordSecondTimeTextfield]
                    .forEach { $0?.resignFirstResponder()}
            }.disposed(by: bag)

        // Изменение состояния submitButton
        viewModel.output.submitButtonState
            .subscribe { [weak viewModel] _ in
                viewModel?.input.submitButtonChangeIsEnable() // активирует/деактивирует кнопку
                viewModel?.input.submitButtonChangeAlpha()    // меняет непрозрачность кнопки
                // иметь в виду, что если кнопка прозрачная, то не обязательно она не активная
            }.disposed(by: bag)
    }

    private func addTargetsForButtons() {
        // Действия при клике на submitButton
        uiElements.submitButton.addTarget(self,
                                          action: #selector(submitButtonTapped),
                                          forControlEvents: .touchUpInside)

        // Действия при клике на changeStateButton
        uiElements.changeStateButton.addTarget(self,
                                               action: #selector(changeStateButtonTapped),
                                               forControlEvents: .touchUpInside)

        // Авторизация через google
        uiElements.authButtons.googleButton.addTarget(self,
                                                      action: #selector(googleSignInButtonTapped),
                                                      forControlEvents: .touchUpInside)

        // Авторизация через facebook
        uiElements.authButtons.facebookButton.addTarget(self,
                                                        action: #selector(facebookSignInButtonTapped),
                                                        forControlEvents: .touchUpInside)

        // Авторизация через apple
        uiElements.authButtons.appleButton.addTarget(self,
                                                     action: #selector(appleSignInButtonTapped),
                                                     forControlEvents: .touchUpInside)
    }

    private func addTargetsForTextfields() {
        // Действия при любых изменениях в текстфилдах
        [uiElements.nameTextField,
         uiElements.passwordTestField,
         uiElements.passwordSecondTimeTextfield]
            .forEach {
                $0.textfield
                    .textField
                    .addTarget(self,
                               action: #selector(textfieldTextDidChange),
                               for: .editingChanged)
            }
    }

    private func setupDelegates() {
        uiElements.nameTextField.textfield.delegate = self
        uiElements.passwordTestField.textfield.delegate = self
        uiElements.passwordSecondTimeTextfield.textfield.delegate = self
    }

    // Наблюдатели за появлением/исчезновением клавиатуры
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    // Валидация текстфилдов, чтобы активировать кнопку submitButton
    @objc private func textfieldTextDidChange() {
        let nameTextFieldText = uiElements.nameTextField.textfield.text as String

        /* Проверяются поля для того, чтобы активировать кнопку submitButton или нет
         А также включает/выключает лейбл, говорящий о том, что пароли при регистрации
         не совпадают и других ошибок */
        self.viewModel.input.checkTextfields(
            email: nameTextFieldText,
            password: passwordText,
            secondPassword: secondPasswordText)
    }

    // MARK: - OBJC methods -
    // Реализация тапа кнопки submitButton
    @objc private func submitButtonTapped() {
        let username = uiElements.nameTextField.textfield.text as String
        viewModel.input.presentTabBarController(withEmail: username,
                                                password: passwordText,
                                                sourceButtonType: .submitButtonOrReturnButton,
                                                presenter: self)
    }

    // Реализация логина через google
    @objc private func googleSignInButtonTapped() {
        viewModel.input.presentTabBarController(withEmail: nil,
                                                password: nil,
                                                sourceButtonType: .googleButton,
                                                presenter: self)
    }

    // Реализация логина через Facebook
    @objc private func facebookSignInButtonTapped() {
        viewModel.input.presentTabBarController(withEmail: nil,
                                                password: nil,
                                                sourceButtonType: .facebookButton,
                                                presenter: self)
    }

    private var appleIDTokenClosure: (() -> String)?

    // Реализация логина через Apple
    @objc private func appleSignInButtonTapped() {
        viewModel.input.startAppleAuthFlow(delegate: self,
                                           presentationContextProvider: self)
    }

    // Реализация тапа кнопки changeStateButton
    @objc private func changeStateButtonTapped() {
        // стираем заранее сохраненные пароли их текстфилдов
        passwordText = ""
        secondPasswordText = ""
        // отчищаются текстфилды
        viewModel.input.cleanTextfields()
        viewModel.input.changeViewControllerState()
        // переключаем состояние контроллера между авторизацией и регистрацией
        viewModel.input.disableSubmitButton() // Отключаем submitButton
        node.transitionLayout(withAnimation: true, shouldMeasureAsync: false) // обновляем лейаут
    }

    // Работа с показом клавиатуры
    @objc private func keyboardWillShow(notification: NSNotification) {
        if !isKeyboardShown {
            isKeyboardShown = true
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey],
                  let keyboardFrameValue = keyboardFrame as? NSValue else { return }
            let keyboardRectangle = keyboardFrameValue.cgRectValue
            let kbHeight = keyboardRectangle.height
            keyboardHeight = kbHeight
            node.transitionLayout(withAnimation: true, shouldMeasureAsync: false) // обновляем лейаут
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        if isKeyboardShown {
            isKeyboardShown = false
            keyboardHeight = 0
            node.transitionLayout(withAnimation: true, shouldMeasureAsync: false) // обновляем лейаут
        }
    }
}

// MARK: - extension + UITextFieldDelegate -
extension RegisterViewController: UITextFieldDelegate {

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == uiElements.passwordTestField.textfield.textField {
            passwordText = ""
        }

        if textField == uiElements.passwordSecondTimeTextfield.textfield.textField {
            secondPasswordText = ""
        }

        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Если кнопка submitButton активна, перекидываем на tabBarController
        switch viewModel.output.submitButtonState.value {
        case .enable:
            viewModel.input.presentTabBarController(withEmail: uiElements.nameTextField.textfield.text as String,
                                                    password: passwordText,
                                                    sourceButtonType: .submitButtonOrReturnButton,
                                                    presenter: self)
        case .disable:
            /*
             Если кнопка submitButton не активна, определяем, какой текстфилд сделать респондером
             в зависимости от ошибок
             */
            let nameTF = uiElements.nameTextField.textfield
            let passwordTF = uiElements.passwordTestField.textfield
            let secondPasswordTF = uiElements.passwordSecondTimeTextfield.textfield

            viewModel.input
                .becomeFirstResponderOrClearOffTextfields(emailTextField: nameTF,
                                                          passwordTestField: passwordTF,
                                                          passwordSecondTimeTextfield: secondPasswordTF,
                                                          password: passwordText,
                                                          secondPassword: secondPasswordText,
                                                          presenter: self)
        }
        return true
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        if  textField == uiElements.passwordTestField.textfield.textField ||
                textField == uiElements.passwordSecondTimeTextfield.textfield.textField {
            return savePasswordFromTextfieldBeforeReplacementWithDot(string: string,
                                                                     range: range,
                                                                     textfield: textField)
        }
        return true
    }

    /* Метод для того, чтобы сохранить пароль из текстфилдов и заменить символы
     на точки (исправления бага с isSecureTextEntry, когда текст прыгает при стирании с кастомным шрифтом)*/

    private func savePasswordFromTextfieldBeforeReplacementWithDot(string: String,
                                                                   range: NSRange,
                                                                   textfield: UITextField) -> Bool {
        var hashPassword = ""
        let newChar = string.first

        if textfield == uiElements.passwordTestField.textfield.textField {
            let offsetToUpdate = passwordText.index(passwordText.startIndex, offsetBy: range.location)

            if string == "" {
                passwordText.remove(at: offsetToUpdate)
                return true
            } else {
                passwordText.insert(newChar!, at: offsetToUpdate)
            }

            for _ in 0..<passwordText.count {  hashPassword += "\u{2022}" }
            textfield.text = hashPassword
        } else if textfield == uiElements.passwordSecondTimeTextfield.textfield.textField {
            let offsetToUpdate = secondPasswordText.index(secondPasswordText.startIndex, offsetBy: range.location)

            if string == "" {
                secondPasswordText.remove(at: offsetToUpdate)
                return true
            } else {
                secondPasswordText.insert(newChar!, at: offsetToUpdate)
            }

            for _ in 0..<secondPasswordText.count {  hashPassword += "\u{2022}" }
            textfield.text = hashPassword
        }

        return false
    }
}

// MARK: - extension + ASAuthorizationControllerDelegate  -
extension RegisterViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredentials = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let appleIDToken = appleIDCredentials.identityToken else {
                assertionFailure() // TODO: Залогировать
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                assertionFailure() // TODO: Залогировать
                return
            }

            guard let appleAuthClosure = viewModel.output.appleAuthClosure else { return }
            viewModel.input.authInApple(single: appleAuthClosure(idTokenString), presenter: self)
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // TODO: Залогировать
        viewModel.input.showAppleAuthError(presenter: self)
    }
}

// MARK: - extension + ASAuthorizationControllerDelegate  -
extension RegisterViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let appDelegate = UIApplication.shared.delegate,
              let window = appDelegate.window,
              let window = window else { return UIWindow() }
        return window
    }
}

// swiftlint:disable:this file_length
