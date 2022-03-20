//
//  RegisterViewController.swift
//  MyChat
//
//  Created by Борис on 14.02.2022.
//

import UIKit
import RxSwift
import RxCocoa

fileprivate final class RegisterUIElements {

    // MARK: - Public properties
    let titleLabel: UILabel = {
        return $0
    }(UILabel())

    let nameTextField: UITextField = {
        $0.placeholder = Text.textfield(.username).text
        $0.backgroundColor = .white
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.returnKeyType = .continue
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

fileprivate final class LayoutConstraints {

    // MARK: - Public properties
    var submitButtonWidth: NSLayoutConstraint?
    var changeStateButtonWidth: NSLayoutConstraint?
}

private enum RegisterViewLocalConstants {

    // textfields
    static let nameTextfieldTopInset: CGFloat = 200
    static let textfieldsWidth: CGFloat = 150
    static let textfieldsHeight: CGFloat = 30
    static let textfieldsSpacing: CGFloat = 10
    // submitButton
    static let submitButtonBottomInset: CGFloat = -60
    // changeToLoginButton
    static let changeToLoginButtonTopInset: CGFloat = 10
}

final class RegisterViewController: UIViewController {

    // MARK: - Private properties
    private let registerViewModel: RegisterViewModelProtocol
    private let ui = RegisterUIElements()
    private let constraints = LayoutConstraints()
    private let bag = DisposeBag()

    // MARK: - Init
    init(registerViewModel: RegisterViewModelProtocol) {
        self.registerViewModel = registerViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()
        addSubviews()
        setupDelegates()
        layout()
        view.backgroundColor = .darkGray // TODO: Удалить
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }

    // MARK: - Private methods
    private func subscribe() {
        registerViewModel.submitButtonTitle
            .bind(to: ui.submitButton.rx.title(for: .normal))
            .disposed(by: bag)

        registerViewModel.changeStateButtonTitle
            .bind(to: ui.changeStateButton.rx.title(for: .normal))
            .disposed(by: bag)

        registerViewModel.passwordSecondTimeTextfieldIsHidden
            .bind(to: ui.passwordSecondTimeTextfield.rx.isHidden)
            .disposed(by: bag)

        registerViewModel.submitButtonIsEnable
            .bind(to: ui.submitButton.rx.isEnabled)
            .disposed(by: bag)

        registerViewModel.nameTextfieldText
            .bind(to: ui.nameTextField.rx.text)
            .disposed(by: bag)

        registerViewModel.passwordTextfieldText
            .bind(to: ui.passwordTestField.rx.text)
            .disposed(by: bag)

        registerViewModel.secondPasswordTextfieldText
            .bind(to: ui.passwordSecondTimeTextfield.rx.text)
            .disposed(by: bag)

        registerViewModel.submitButtonAlpha
            .bind(to: ui.submitButton.rx.alpha)
            .disposed(by: bag)

        // Change registerViewController state
        registerViewModel.viewControllerState.subscribe { [weak self] _ in
            self?.registerViewModel.secondTimeTextfieldIsHiddenToggle()
            self?.registerViewModel.changeButtonsTitle()
            self?.layoutButtons()
        }.disposed(by: bag)

        // Change submitButtonState
        registerViewModel.submitButtonState.subscribe { [weak self] _ in
            self?.registerViewModel.submitButtonChangeAlpha()
            self?.registerViewModel.submitButtonIsEnableToggle()
        }.disposed(by: bag)

        // Textfields checking
        Observable.combineLatest(ui.nameTextField.rx.text,
                                 ui.passwordTestField.rx.text,
                                 ui.passwordSecondTimeTextfield.rx.text)
            .subscribe { [weak self] _ in
                self?.checkTextfields()
            }
            .disposed(by: bag)

        // SubmitButton tapped
        ui.submitButton.rx.tap.subscribe { [weak self] _ in
            self?.registerViewModel.presentTabBarController()
        }.disposed(by: bag)

        // AuthButton tapped
        ui.changeStateButton.rx.tap.subscribe { [weak self] _ in
            self?.registerViewModel.cleanTextfields()

            self?.registerViewModel.viewControllerState.value == .register
            ? self?.registerViewModel.viewControllerState.accept(.auth)
            : self?.registerViewModel.viewControllerState.accept(.register)

            self?.registerViewModel.submitButtonState.accept(.disable)
        }
        .disposed(by: bag)
    }

    private func addSubviews() {
        view.addSubview(ui.nameTextField)
        view.addSubview(ui.passwordTestField)
        view.addSubview(ui.passwordSecondTimeTextfield)
        view.addSubview(ui.submitButton)
        view.addSubview(ui.changeStateButton)
    }

    private func layout() {
        for view in view.subviews {
            view.translatesAutoresizingMaskIntoConstraints = false
        }

        ui.submitButton.sizeToFit()
        ui.changeStateButton.sizeToFit()
        let submitButtonSize = ui.submitButton.frame.size
        let changeToLoginButtonSize = ui.changeStateButton.frame.size

        constraints.submitButtonWidth = ui.submitButton
            .widthAnchor
            .constraint(equalToConstant: submitButtonSize.width)
        constraints.changeStateButtonWidth = ui.changeStateButton
            .widthAnchor
            .constraint(equalToConstant: changeToLoginButtonSize.width)

        constraints.submitButtonWidth?.isActive = true
        constraints.changeStateButtonWidth?.isActive = true

        NSLayoutConstraint.activate([

            // nameTextField
            ui.nameTextField
                .topAnchor
                .constraint(equalTo: view.topAnchor,
                            constant: RegisterViewLocalConstants.nameTextfieldTopInset),

            ui.nameTextField
                .centerXAnchor
                .constraint(equalTo: view.centerXAnchor),

            ui.nameTextField
                .widthAnchor
                .constraint(equalToConstant: RegisterViewLocalConstants.textfieldsWidth),

            ui.nameTextField
                .heightAnchor
                .constraint(equalToConstant: RegisterViewLocalConstants.textfieldsHeight),

            // passwordTestField

            ui.passwordTestField
                .topAnchor
                .constraint(equalTo: ui.nameTextField.bottomAnchor,
                            constant: RegisterViewLocalConstants.textfieldsSpacing),

            ui.passwordTestField
                .centerXAnchor
                .constraint(equalTo: view.centerXAnchor),

            ui.passwordTestField
                .widthAnchor
                .constraint(equalToConstant: RegisterViewLocalConstants.textfieldsWidth),

            ui.passwordTestField
                .heightAnchor
                .constraint(equalToConstant: RegisterViewLocalConstants.textfieldsHeight),

            // passwordSecondTimeTextfield
            ui.passwordSecondTimeTextfield
                .topAnchor
                .constraint(equalTo: ui.passwordTestField.bottomAnchor,
                            constant: RegisterViewLocalConstants.textfieldsSpacing),

            ui.passwordSecondTimeTextfield
                .centerXAnchor
                .constraint(equalTo: view.centerXAnchor),

            ui.passwordSecondTimeTextfield
                .widthAnchor
                .constraint(equalToConstant: RegisterViewLocalConstants.textfieldsWidth),

            ui.passwordSecondTimeTextfield
                .heightAnchor
                .constraint(equalToConstant: RegisterViewLocalConstants.textfieldsHeight),

            // submitButton
            ui.submitButton
                .heightAnchor
                .constraint(equalToConstant: submitButtonSize.height),

            ui.submitButton
                .bottomAnchor
                .constraint(equalTo: view.bottomAnchor,
                            constant: RegisterViewLocalConstants.submitButtonBottomInset),

            ui.submitButton
                .centerXAnchor
                .constraint(equalTo: view.centerXAnchor),

            // changeToLoginButton
            ui.changeStateButton
                .topAnchor
                .constraint(equalTo: ui.submitButton.bottomAnchor,
                            constant: RegisterViewLocalConstants.changeToLoginButtonTopInset),

            ui.changeStateButton
                .centerXAnchor
                .constraint(equalTo: ui.submitButton.centerXAnchor),

            ui.changeStateButton
                .heightAnchor
                .constraint(equalToConstant: changeToLoginButtonSize.height)
        ])
    }

    private func layoutButtons() {
        ui.submitButton.sizeToFit()
        ui.changeStateButton.sizeToFit()

        let submitButtonWidth = ui.submitButton.frame.size.width
        let changeToLoginButtonWidth = ui.changeStateButton.frame.size.width

        constraints.submitButtonWidth?.constant = submitButtonWidth
        constraints.changeStateButtonWidth?.constant = changeToLoginButtonWidth

        ui.submitButton.layoutIfNeeded()
        ui.changeStateButton.layoutIfNeeded()
    }

    private func setupDelegates() {
        ui.nameTextField.delegate = self
        ui.passwordTestField.delegate = self
        ui.passwordSecondTimeTextfield.delegate = self
    }

    private func showAlertController() {
        let alertController = registerViewModel.showAlertController()
        present(alertController, animated: true)
    }

    private func checkTextfields() {
        let name = ui.nameTextField.text
        let password = ui.passwordTestField.text
        let secondPassword = ui.passwordSecondTimeTextfield.text

        registerViewModel.checkTextfields(name: name,
                                          password: password,
                                          secondPassword: secondPassword)
    }
}

// MARK: - extension + UITextFieldDelegate
extension RegisterViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        switch registerViewModel.submitButtonState.value {
        case .enable:
            registerViewModel.presentTabBarController()

        case .disable:
            if ui.nameTextField.text != ""
                && ui.passwordTestField.text != ""
                && ui.passwordSecondTimeTextfield.text != "" {

                showAlertController()
                ui.nameTextField.rx.text.onNext("")
                ui.passwordTestField.rx.text.onNext("")
                ui.passwordSecondTimeTextfield.rx.text.onNext("")

            } else if  (ui.nameTextField.text != ""
                        || ui.passwordTestField.text != ""
                        || ui.passwordSecondTimeTextfield.text != "")
                        || (ui.nameTextField.text == ""
                            && ui.passwordTestField.text == ""
                            && ui.passwordSecondTimeTextfield.text == "") {

                let textfieldArray = [ui.nameTextField, ui.passwordTestField, ui.passwordSecondTimeTextfield]

                for textfield in textfieldArray {
                    if textfield.text == "" {
                        textfield.becomeFirstResponder()
                        break
                    }
                }

            } else {
                showAlertController()
            }
        }
        return true
    }
}
