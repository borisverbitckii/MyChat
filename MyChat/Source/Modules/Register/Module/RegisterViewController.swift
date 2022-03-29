//
//  RegisterViewController.swift
//  MyChat
//
//  Created by Борис on 14.02.2022.
//

import UIKit
import RxSwift
import RxCocoa

// Все константы для верстки вынесены отдельно
private enum RegisterViewLocalConstants {
    // Textfields
    static let nameTextfieldTopInset: CGFloat = 200
    static let textfieldsWidth: CGFloat = 150
    static let textfieldsHeight: CGFloat = 30
    static let textfieldsSpacing: CGFloat = 10
    // SubmitButton
    static let submitButtonBottomInset: CGFloat = -10
    // ChangeToLoginButton
    static let changeToLoginButtonBottomInset: CGFloat = -30
    // PasswordErrorLabel
    static let passwordErrorLabelIndex: CGFloat = -10
}

// Констрейнты для обновления клавиатуры
final class RegisterConstraints {
    static var changeStateBottomAnchor: NSLayoutConstraint?
}

// swiftlint:disable:next type_body_length
final class RegisterViewController: UIViewController {
    // MARK: - Private properties -
    private let uiElements = RegisterUIElements() // вынесенные UI элементы
    private let registerViewModel: RegisterViewModelProtocol
    private let bag = DisposeBag()
    private var isKeyboardShown = false // проперти, чтобы не было глюков для появления/исчезновения клавиатуры

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
        bindUIElements() // бинд значений из вью модели напрямую в ui элементы
        subscribeToObservables() // основное взаимодействие с вьюмоделью
        setupDelegates() // делегаты для текстфилдов, чтобы по клику на return осуществлялся переход в след текстфилд
        addKeyboardObservers() // наблюдение за клавиатурой
        view.backgroundColor = .darkGray
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Скрываем клавиатуру при клику на любую область
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }

    // MARK: - Private methods -
    private func bindUIElements() {
        // Бинд всех данных из вью модели в ui елементы
        registerViewModel.submitButtonTitle
            .bind(to: uiElements.submitButton.rx.title(for: .normal))
            .disposed(by: bag)

        registerViewModel.changeStateButtonTitle
            .bind(to: uiElements.changeStateButton.rx.title(for: .normal))
            .disposed(by: bag)

        registerViewModel.passwordSecondTimeTextfieldIsHidden
            .bind(to: uiElements.passwordSecondTimeTextfield.rx.isHidden)
            .disposed(by: bag)

        registerViewModel.submitButtonIsEnable // делат кнопку активной или не активной на строке (129)
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

        registerViewModel.errorPasswordLabelText
            .bind(to: uiElements.passwordsErrorLabel.rx.text)
            .disposed(by: bag)

        registerViewModel.errorPasswordLabelState
            .bind(to: uiElements.passwordsErrorLabel.rx.isHidden)
            .disposed(by: bag)
    }

    private func subscribeToObservables() {
        // Изменение состояния registerViewController

        // Всего 2 состояния для контроллера: авторизация и регистрация
        // - В зависимости от состояния мы либо показываем текст филд для дублирования пароля, или нет(120)
        // - Меняем текст в кнопке для смены состояния контроллера (самая нижняя) (121)
        // - Выключаем лейбл, который говорит о несовпадении паролей при регистрации (122)
        registerViewModel.viewControllerState
            .subscribe { [weak self] _ in
                self?.registerViewModel.secondTimeTextfieldIsHiddenToggle()
                self?.registerViewModel.changeButtonsTitle()
                self?.registerViewModel.disableErrorLabel()

                [self?.uiElements.nameTextField,
                 self?.uiElements.passwordTestField,
                 self?.uiElements.passwordSecondTimeTextfield]
                    .forEach { $0?.resignFirstResponder()}
            }.disposed(by: bag)

        // Изменение состояния submitButton
        // Подписка на состояние кнопки submitButtonState (активное и не активное)
        registerViewModel.submitButtonState
            .subscribe { [weak self] _ in
                self?.registerViewModel.submitButtonChangeIsEnable() // активирует деактивирует кнопку
                self?.registerViewModel.submitButtonChangeAlpha() // меняет непрозрачность кнопки
                // иметь в виду, что если кнопка прозрачная, то не обязательно она не активная

            }.disposed(by: bag)

        // Проверка содержимого текстфилдов
        // Все обновления филдов собираются в единый поток
        Observable
            .combineLatest(uiElements.nameTextField.rx.text,
                           uiElements.passwordTestField.rx.text,
                           uiElements.passwordSecondTimeTextfield.rx.text)
            .subscribe { [weak self] _ in
                let nameTextFieldText = self?.uiElements.nameTextField.text
                let passwordTestFieldText = self?.uiElements.passwordTestField.text
                let passwordSecondTimeTextfieldText = self?.uiElements.passwordSecondTimeTextfield.text
                // Проверяются поля для того, чтобы активировать кнопку submitButton или нет
                // А также включает/выключает лейбл, говорящий о том, что пароли при регистрации не совпадают
                self?.registerViewModel.checkTextfields(name: nameTextFieldText,
                                                        password: passwordTestFieldText,
                                                        secondPassword: passwordSecondTimeTextfieldText)
            }
            .disposed(by: bag)

        // Действия при клике на submitButton
        uiElements.submitButton.rx
            .tap
            .subscribe { [weak self] _ in
                self?.registerViewModel.presentTabBarController()
            }
            .disposed(by: bag)

        // Действия при клике на changeStateButton
        uiElements.changeStateButton.rx
            .tap
            .subscribe { [weak self] _ in
                self?.registerViewModel.cleanTextfields() // отчищаются текстфилды
                self?.registerViewModel.changeViewControllerState()
                // переключаем состояние контроллера между авторизацией и регистрацией
                self?.registerViewModel.disableSubmitButton() // Отключаем submitButton
            }
            .disposed(by: bag)
    }

    private func addSubviews() {
        view.addSubview(uiElements.nameTextField)
        view.addSubview(uiElements.passwordTestField)
        view.addSubview(uiElements.passwordSecondTimeTextfield)
        view.addSubview(uiElements.passwordsErrorLabel)
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
        layoutChangeStateButton()
        layoutSubmitButton()
        layoutPasswordErrorLabel()
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

    private func layoutChangeStateButton() {
        // Вытаскиваем отдельно констрейнт для нижней кнопки, чтобы менять значения при показе клавиатуры
        RegisterConstraints.changeStateBottomAnchor = uiElements.changeStateButton
            .bottomAnchor
            .constraint(equalTo: view.bottomAnchor,
                        constant: RegisterViewLocalConstants.changeToLoginButtonBottomInset)

        guard let changeStateBottomAnchor = RegisterConstraints.changeStateBottomAnchor else { return }

        NSLayoutConstraint.activate([
            changeStateBottomAnchor,

            uiElements.changeStateButton
                .centerXAnchor
                .constraint(equalTo: uiElements.submitButton.centerXAnchor)
        ])
    }

    private func layoutSubmitButton() {
        NSLayoutConstraint.activate([
            uiElements.submitButton
                .bottomAnchor
                .constraint(equalTo: uiElements.changeStateButton.topAnchor,
                            constant: RegisterViewLocalConstants.submitButtonBottomInset),

            uiElements.submitButton
                .centerXAnchor
                .constraint(equalTo: view.centerXAnchor)])
    }

    private func layoutPasswordErrorLabel() {
        NSLayoutConstraint.activate([
            uiElements.passwordsErrorLabel
                .bottomAnchor
                .constraint(equalTo: uiElements.submitButton.topAnchor,
                            constant: RegisterViewLocalConstants.passwordErrorLabelIndex),

            uiElements.passwordsErrorLabel
                .centerXAnchor
                .constraint(equalTo: view.centerXAnchor)
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
    // Работа с показом клавиатуры
    @objc private func keyboardWillShow(notification: NSNotification) {
        if !isKeyboardShown {
            isKeyboardShown = true
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey],
                  let keyboardFrameValue = keyboardFrame as? NSValue else { return }

            let keyboardRectangle = keyboardFrameValue.cgRectValue
            let kbHeight = keyboardRectangle.height

            let changeStateBottomAnchor = RegisterConstraints.changeStateBottomAnchor
            changeStateBottomAnchor?.constant = RegisterViewLocalConstants.changeToLoginButtonBottomInset - kbHeight

            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        if isKeyboardShown {
            isKeyboardShown = false

            let changeStateBottomAnchor = RegisterConstraints.changeStateBottomAnchor
            changeStateBottomAnchor?.constant = RegisterViewLocalConstants.changeToLoginButtonBottomInset

            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - extension + UITextFieldDelegate
extension RegisterViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Если кнопка submitButton активна, перекидываем на tabBarController
        switch registerViewModel.submitButtonState.value {
        case .enable:
            registerViewModel.presentTabBarController()
        case .disable:
            // Если кнопка submitButton не активна, определяем, какой текстфилд сделать респондером
            // (пример: выбираем 3 текстфилд, кликаем в клавиатуре continue,
            // респондером сделается тот филд, который самый верхний и не заполненный)
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
