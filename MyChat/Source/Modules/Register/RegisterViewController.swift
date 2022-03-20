//
//  RegisterViewController.swift
//  MyChat
//
//  Created by Борис on 14.02.2022.
//

import UIKit
import RxSwift
import RxCocoa

private enum RegisterViewLocalConstants {
    // Textfields
    static let nameTextfieldTopInset: CGFloat = 200
    static let textfieldsWidth: CGFloat = 150
    static let textfieldsHeight: CGFloat = 30
    static let textfieldsSpacing: CGFloat = 10
    // SubmitButton
    static let submitButtonBottomInset: CGFloat = -100
    // ChangeToLoginButton
    static let changeToLoginButtonTopInset: CGFloat = 10
}

private final class LayoutConstraints {
    // MARK: - Public properties -
    var submitButtonWidth: NSLayoutConstraint?
    var changeStateButtonWidth: NSLayoutConstraint?
}

private final class RegisterUIElements {
    // MARK: - Public methods -
    let titleLabel: UILabel = {
        return $0
    }(UILabel())

    let nameTextField: UITextField = {
        $0.placeholder = Text.textfield(.username).text
        $0.backgroundColor = .white
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.returnKeyType = .continue
        $0.textContentType = .username
        return $0
    }(UITextField())

    let passwordTestField: UITextField = {
        $0.placeholder = Text.textfield(.password(.first)).text
        $0.backgroundColor = .white
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.returnKeyType = .continue
        $0.textContentType = .password
        return $0
    }(UITextField())

    let passwordSecondTimeTextfield: UITextField = {
        $0.placeholder = Text.textfield(.password(.second)).text
        $0.backgroundColor = .white
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.returnKeyType = .continue
        $0.textContentType = .password
        return $0
    }(UITextField())

    let submitButton: UIButton = {
        $0.backgroundColor = .red
        return $0
    }(UIButton(type: .custom))

    let changeStateButton: UIButton = {
        $0.backgroundColor = .gray
        return $0
    }(UIButton(type: .system))
}

final class RegisterViewController: UIViewController {
    // MARK: - Private properties -
    private let uiElements = RegisterUIElements()
    private let registerViewModel: RegisterViewModelProtocol
    private let bag = DisposeBag()

    private var defaultSubmitButtonsFrame: CGRect?
    private var defaultChangeStateButtonFrame: CGRect?
    private var isKeyboardShown = false

    // MARK: - Init -
    init(registerViewModel: RegisterViewModelProtocol) {
        self.registerViewModel = registerViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override methods -
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        layout()
        bindUIElements()
        subscribeToObservables()
        setupDelegates()
        addKeyboardObservers()
        view.backgroundColor = .darkGray
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }

    // MARK: - Private methods -
    private func bindUIElements() {
        registerViewModel.submitButtonTitle
            .bind(to: uiElements.submitButton.rx.title(for: .normal))
            .disposed(by: bag)

        registerViewModel.changeStateButtonTitle
            .bind(to: uiElements.changeStateButton.rx.title(for: .normal))
            .disposed(by: bag)

        registerViewModel.passwordSecondTimeTextfieldIsHidden
            .bind(to: uiElements.passwordSecondTimeTextfield.rx.isHidden)
            .disposed(by: bag)

        registerViewModel.submitButtonIsEnable
            .bind(to: uiElements.submitButton.rx.isEnabled)
            .disposed(by: bag)

        registerViewModel.nameTextfieldText
            .bind(to: uiElements.nameTextField.rx.text)
            .disposed(by: bag)

        registerViewModel.passwordTextfieldText
            .bind(to: uiElements.passwordTestField.rx.text)
            .disposed(by: bag)

        registerViewModel.secondPasswordTextfieldText
            .bind(to: uiElements.passwordSecondTimeTextfield.rx.text)
            .disposed(by: bag)

        registerViewModel.submitButtonAlpha
            .bind(to: uiElements.submitButton.rx.alpha)
            .disposed(by: bag)
    }

    private func subscribeToObservables() {
        // Change registerViewController state
        registerViewModel.viewControllerState
            .subscribe { [weak self] _ in
                self?.registerViewModel.secondTimeTextfieldIsHiddenToggle()
                self?.registerViewModel.changeButtonsTitle()
            }.disposed(by: bag)

        // Change submitButtonState
        registerViewModel.submitButtonState
            .subscribe { [weak self] _ in
                self?.registerViewModel.submitButtonChangeAlpha()
                self?.registerViewModel.submitButtonIsEnableToggle()
            }.disposed(by: bag)

        // Textfields checking
        Observable
            .combineLatest(uiElements.nameTextField.rx.text,
                           uiElements.passwordTestField.rx.text,
                           uiElements.passwordSecondTimeTextfield.rx.text)
            .subscribe { [weak self] _ in
                let nameTextFieldText = self?.uiElements.nameTextField.text
                let passwordTestFieldText = self?.uiElements.passwordTestField.text
                let passwordSecondTimeTextfieldText = self?.uiElements.passwordSecondTimeTextfield.text

                self?.registerViewModel.checkTextfields(name: nameTextFieldText,
                                                        password: passwordTestFieldText,
                                                        secondPassword: passwordSecondTimeTextfieldText)
            }
            .disposed(by: bag)

        // SubmitButton tapped
        uiElements.submitButton.rx
            .tap
            .subscribe { [weak self] _ in
                self?.registerViewModel.presentTabBarController()
            }.disposed(by: bag)

        // AuthButton tapped
        uiElements.changeStateButton.rx
            .tap
            .subscribe { [weak self] _ in
                self?.registerViewModel.cleanTextfields()

                self?.registerViewModel.removeLastFirstResponderTextfield()

                self?.registerViewModel.viewControllerState.value == .register
                ? self?.registerViewModel.viewControllerState.accept(.auth)
                : self?.registerViewModel.viewControllerState.accept(.register)

                self?.registerViewModel.submitButtonState.accept(.disable)
            }
            .disposed(by: bag)
    }

    private func addSubviews() {
        view.addSubview(uiElements.nameTextField)
        view.addSubview(uiElements.passwordTestField)
        view.addSubview(uiElements.passwordSecondTimeTextfield)
        view.addSubview(uiElements.submitButton)
        view.addSubview(uiElements.changeStateButton)
    }

    private func layout() {
        for view in view.subviews {
            view.translatesAutoresizingMaskIntoConstraints = false
        }

        layoutNameTextField()
        layoutPasswordTestField()
        layoutPasswordSecondTimeTextfield()
        layoutSubmitButton()
        layoutChangeStateButton()
    }

    private func layoutNameTextField() {
        NSLayoutConstraint.activate([
            uiElements.nameTextField
                .topAnchor
                .constraint(equalTo: view.topAnchor,
                            constant: RegisterViewLocalConstants.nameTextfieldTopInset),

            uiElements.nameTextField
                .centerXAnchor
                .constraint(equalTo: view.centerXAnchor),

            uiElements.nameTextField
                .widthAnchor
                .constraint(equalToConstant: RegisterViewLocalConstants.textfieldsWidth),

            uiElements.nameTextField
                .heightAnchor
                .constraint(equalToConstant: RegisterViewLocalConstants.textfieldsHeight)
        ])
    }

    private func layoutPasswordTestField() {
        NSLayoutConstraint.activate([
            uiElements.passwordTestField
                .topAnchor
                .constraint(equalTo: uiElements.nameTextField.bottomAnchor,
                            constant: RegisterViewLocalConstants.textfieldsSpacing),

            uiElements.passwordTestField
                .centerXAnchor
                .constraint(equalTo: view.centerXAnchor),

            uiElements.passwordTestField
                .widthAnchor
                .constraint(equalToConstant: RegisterViewLocalConstants.textfieldsWidth),

            uiElements.passwordTestField
                .heightAnchor
                .constraint(equalToConstant: RegisterViewLocalConstants.textfieldsHeight)
        ])
    }

    private func layoutPasswordSecondTimeTextfield() {
        NSLayoutConstraint.activate([
            uiElements.passwordSecondTimeTextfield
                .topAnchor
                .constraint(equalTo: uiElements.passwordTestField.bottomAnchor,
                            constant: RegisterViewLocalConstants.textfieldsSpacing),

            uiElements.passwordSecondTimeTextfield
                .centerXAnchor
                .constraint(equalTo: view.centerXAnchor),

            uiElements.passwordSecondTimeTextfield
                .widthAnchor
                .constraint(equalToConstant: RegisterViewLocalConstants.textfieldsWidth),

            uiElements.passwordSecondTimeTextfield
                .heightAnchor
                .constraint(equalToConstant: RegisterViewLocalConstants.textfieldsHeight)
        ])
    }

    private func layoutSubmitButton() {
        NSLayoutConstraint.activate([
            uiElements.submitButton
                .bottomAnchor
                .constraint(equalTo: view.bottomAnchor,
                            constant: RegisterViewLocalConstants.submitButtonBottomInset),

            uiElements.submitButton
                .centerXAnchor
                .constraint(equalTo: view.centerXAnchor)])
    }

    private func layoutChangeStateButton() {
        NSLayoutConstraint.activate([
            uiElements.changeStateButton
                .topAnchor
                .constraint(equalTo: uiElements.submitButton.bottomAnchor,
                            constant: RegisterViewLocalConstants.changeToLoginButtonTopInset),

            uiElements.changeStateButton
                .centerXAnchor
                .constraint(equalTo: uiElements.submitButton.centerXAnchor)
        ])
    }

    private func setupDelegates() {
        uiElements.nameTextField.delegate = self
        uiElements.passwordTestField.delegate = self
        uiElements.passwordSecondTimeTextfield.delegate = self
    }

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

    // MARK: - OBJC methods -
    @objc private func keyboardWillShow(notification: NSNotification) {
        if !isKeyboardShown {
            isKeyboardShown = true
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey],
                  let keyboardFrameValue = keyboardFrame as? NSValue else { return }

            let keyboardRectangle = keyboardFrameValue.cgRectValue
            let keyboardHeight = keyboardRectangle.height

            defaultSubmitButtonsFrame = uiElements.submitButton.frame
            defaultChangeStateButtonFrame = uiElements.changeStateButton.frame

            uiElements.submitButton.frame = CGRect(x: uiElements.submitButton.frame.minX,
                                                   y: uiElements.submitButton.frame.minY - keyboardHeight,
                                                   width: uiElements.submitButton.frame.width,
                                                   height: uiElements.submitButton.frame.height)
            uiElements.changeStateButton.frame = CGRect(x: uiElements.changeStateButton.frame.minX,
                                                        y: uiElements.changeStateButton.frame.minY - keyboardHeight,
                                                        width: uiElements.changeStateButton.frame.width,
                                                        height: uiElements.changeStateButton.frame.height)
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        if isKeyboardShown {
            isKeyboardShown = false
            guard let defaultSubmitButtonsFrame = defaultSubmitButtonsFrame,
                  let defaultChangeStateButtonFrame = defaultChangeStateButtonFrame else { return }

            uiElements.submitButton.frame = defaultSubmitButtonsFrame
            uiElements.changeStateButton.frame = defaultChangeStateButtonFrame
        }
    }
}

// MARK: - extension + UITextFieldDelegate
extension RegisterViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch registerViewModel.submitButtonState.value {
        case .enable:
            registerViewModel.presentTabBarController()
        case .disable:
            let nameTF = uiElements.nameTextField
            let passwordTF = uiElements.passwordTestField
            let secondPasswordTF = uiElements.passwordSecondTimeTextfield

            registerViewModel.becomeFirstResponderOrClearOffTextfields(nameTextField: nameTF,
                                                                       passwordTestField: passwordTF,
                                                                       passwordSecondTimeTextfield: secondPasswordTF,
                                                                       presenter: self)
        }
        return false
    }
}
