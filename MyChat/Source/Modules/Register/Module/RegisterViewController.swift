//
//  RegisterViewController.swift
//  MyChat
//
//  Created by Борис on 14.02.2022.
//

import RxSwift
import AsyncDisplayKit

// Все константы для верстки вынесены отдельно
private enum RegisterViewLocalConstants {
    // Текстфилды
    static let textfieldsStackSpacing: CGFloat = 20
    static let textfieldsSize = CGSize(width: 250,
                                       height: 40)
    static let textfieldsStackTopInset: CGFloat = 150
    // Кнопки
    static let buttonsSize = CGSize(width: 250,
                                       height: 40)
    // SafeAreaInsets
    static let bottomInset: CGFloat = 32
}

// swiftlint:disable:next type_body_length
final class RegisterViewController: ASDKViewController<ASDisplayNode> {
    // MARK: - Private properties -
    private let uiElements = RegisterUIElements() // вынесенные UI элементы
    private let viewModel: RegisterViewModelProtocol
    private let bag = DisposeBag()
    private var isKeyboardShown = false           // чтобы убрать глюки появления/исчезновения клавиатуры
    private var keyboardHeight: CGFloat = 0

    // MARK: - Init -
    init(registerViewModel: RegisterViewModelProtocol) {
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
        node.backgroundColor = .gray
        bindUIElements()          // Бинд значений из вью модели напрямую в ui элементы
        subscribeToObservables()  // Основное взаимодействие с вьюмоделью
        addTargetsForButtons()    // Реализация тапов по кнопкам
        addTargetsForTextfields() // Проверка текстфилдов, чтобы активировать кнопку submit
        setupDelegates()          // Делегаты для текстфилдов, чтобы по клику на
                                  // return осуществлялся переход в след текстфилд
        addKeyboardObservers()    // Наблюдение за клавиатурой
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
            // Текстфилды
            let textfieldsChildren = [self.uiElements.nameTextField,
                                      self.uiElements.passwordTestField,
                                      self.uiElements.passwordSecondTimeTextfield]

            let textfiledsVertivalStack = ASStackLayoutSpec()
            textfiledsVertivalStack.direction = .vertical
            textfiledsVertivalStack.spacing = RegisterViewLocalConstants.textfieldsStackSpacing
            textfiledsVertivalStack.horizontalAlignment = .middle
            textfiledsVertivalStack.children = textfieldsChildren

            textfieldsChildren.forEach { $0.style.preferredSize = RegisterViewLocalConstants.textfieldsSize }

            // Кнопки + passwordsErrorLabel
            let labelCenterLayoutSpec = ASCenterLayoutSpec(centeringOptions: .XY,
                                                           sizingOptions: [],
                                                           child: self.uiElements.passwordsErrorLabel)

            let buttonsChildren: [ASLayoutElement] = [labelCenterLayoutSpec,
                                                      self.uiElements.submitButton,
                                                      self.uiElements.changeStateButton]

            let buttonsVerticalStack = ASStackLayoutSpec()
            buttonsVerticalStack.direction = .vertical
            buttonsVerticalStack.horizontalAlignment = .middle
            buttonsVerticalStack.children = buttonsChildren

            buttonsChildren.forEach { $0.style.preferredSize = RegisterViewLocalConstants.buttonsSize }

            let textfieldsInsets = UIEdgeInsets(top: RegisterViewLocalConstants.textfieldsStackTopInset,
                                                left: .infinity,
                                                bottom: .infinity,
                                                right: .infinity)
            let textfieladInsetsSpec = ASInsetLayoutSpec(insets: textfieldsInsets,
                                                         child: textfiledsVertivalStack)
            var buttonsInsets: UIEdgeInsets?
            let bottomInset = RegisterViewLocalConstants.bottomInset
            if self.isKeyboardShown {
                buttonsInsets = UIEdgeInsets(top: .infinity,
                                             left: .infinity,
                                             bottom: self.keyboardHeight + bottomInset ,
                                             right: .infinity)
            } else {
                buttonsInsets = UIEdgeInsets(top: .infinity,
                                             left: .infinity,
                                             bottom: bottomInset,
                                             right: .infinity)
            }
            guard let buttonsInsets = buttonsInsets else { return ASLayoutSpec() }
            let insetsButtonsSpec = ASInsetLayoutSpec(insets: buttonsInsets, child: buttonsVerticalStack)
            let overlayButtonSpec = ASOverlayLayoutSpec(child: textfieladInsetsSpec, overlay: insetsButtonsSpec)

            return overlayButtonSpec
        }
    }

    // swiftlint:disable:next function_body_length
    private func bindUIElements() {
        // Бинд всех данных из вью модели в ui елементы

        // submitButton
        viewModel.output.submitButtonTitle
            .subscribe { [weak self] event in
                self?.uiElements.submitButton.setTitle(event.element?.title ?? "",
                                                       with: event.element?.font,
                                                       with: nil,
                                                       for: .normal)
            }
            .disposed(by: bag)

        viewModel.output.submitButtonIsEnable // делает кнопку активной/не активной в таргете текстфилдов
            .subscribe { [weak self] event in
                self?.uiElements.submitButton.isEnabled = event.element ?? false
            }
            .disposed(by: bag)

        viewModel.output.submitButtonAlpha
            .subscribe { [weak self] event in
                guard let alpha = event.element else { return }
                self?.uiElements.submitButton.alpha = alpha
            }
            .disposed(by: bag)

        // changeStateButton
        viewModel.output.changeStateButtonTitle
            .subscribe { [weak self] event in
                self?.uiElements.changeStateButton.setTitle(event.element?.title ?? "",
                                                            with: event.element?.font,
                                                            with: nil,
                                                            for: .normal)
            }
            .disposed(by: bag)

        // Все текстфилды
        viewModel.output.textfieldsFont
            .subscribe { [weak self] event in
                self?.uiElements.nameTextField.font = event.element
                self?.uiElements.passwordTestField.font = event.element
                self?.uiElements.passwordSecondTimeTextfield.font = event.element
            }
            .disposed(by: bag)

        // nameTextfield
        viewModel.output.nameTextfieldText
            .subscribe { [weak self] event in
                self?.uiElements.nameTextField.text = event.element as NSString?
            }
            .disposed(by: bag)

        viewModel.output.nameTextfieldPlaceholder
            .subscribe { [weak self] event in
                self?.uiElements.nameTextField.placeholder = event.element as NSString?
            }.disposed(by: bag)

        // passwordTextfield
        viewModel.output.passwordTextfieldText
            .subscribe { [weak self] event in
                self?.uiElements.passwordTestField.text = event.element as NSString?
            }
            .disposed(by: bag)

        viewModel.output.passwordTextfieldPlaceholder
            .subscribe { [weak self] event in
                self?.uiElements.passwordTestField.placeholder = event.element as NSString?
            }
            .disposed(by: bag)

        // secondPasswordTextfieldTex
        viewModel.output.secondPasswordTextfieldText
            .subscribe { [weak self] event in
                self?.uiElements.passwordSecondTimeTextfield.text = event.element as? NSString
            }
            .disposed(by: bag)

        viewModel.output.secondPasswordTextfieldPlaceholder
            .subscribe { [weak self] event in
                self?.uiElements.passwordSecondTimeTextfield.placeholder = event.element as NSString?
            }
            .disposed(by: bag)

        viewModel.output.secondPasswordTextfieldIsHidden
            .subscribe { [weak self] event in
                self?.uiElements.passwordSecondTimeTextfield.isHidden = event.element ?? false
            }
            .disposed(by: bag)

        // errorPasswordLabelText
        viewModel.output.errorPasswordLabel
            .subscribe { [weak self] event in
                guard let text = event.element?.text,
                      let font = event.element?.font else { return }
                let attributes = [NSAttributedString.Key.font: font]
                let attributedStringText = NSAttributedString(string: text,
                                                              attributes: attributes)
                self?.uiElements.passwordsErrorLabel.attributedText = attributedStringText
            }
            .disposed(by: bag)

        viewModel.output.errorPasswordLabelState
            .subscribe { [weak self] event in
                guard let isHidden = event.element else { return }
                self?.uiElements.passwordsErrorLabel.isHidden = isHidden
            }
            .disposed(by: bag)

    }

    private func subscribeToObservables() {
        // Подписка на все обсервабл

        /* Изменение состояния registerViewController

         Всего 2 состояния для контроллера: авторизация и регистрация
         - В зависимости от состояния мы либо показываем текст филд для дублирования пароля, или нет
         - Меняем текст в кнопке для смены состояния контроллера (самая нижняя)
         - Выключаем лейбл, который говорит о несовпадении паролей при регистрации
         - ResignFirstResponder для текстфилдов при переключении состояния */

        viewModel.output.viewControllerState
            .subscribe { [weak self] _ in
                self?.viewModel.input.secondTimeTextfieldIsHiddenToggle()
                self?.viewModel.input.changeButtonsTitle()
                self?.viewModel.input.disableErrorLabel()

                [self?.uiElements.nameTextField,
                 self?.uiElements.passwordTestField,
                 self?.uiElements.passwordSecondTimeTextfield]
                    .forEach { $0?.resignFirstResponder()}
            }.disposed(by: bag)

        // Изменение состояния submitButton
        viewModel.output.submitButtonState
            .subscribe { [weak self] _ in
                self?.viewModel.input.submitButtonChangeIsEnable() // активирует/деактивирует кнопку
                self?.viewModel.input.submitButtonChangeAlpha()    // меняет непрозрачность кнопки
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
    }

    private func addTargetsForTextfields() {
        // Действия при любых изменениях в текстфилдах
        [uiElements.nameTextField,
         uiElements.passwordTestField,
         uiElements.passwordSecondTimeTextfield]
            .forEach {
                $0.textField.addTarget(self,
                                       action: #selector(textfieldTextDidChange),
                                       for: .editingChanged)
            }
    }

    private func setupDelegates() {
        uiElements.nameTextField.delegate = self
        uiElements.passwordTestField.delegate = self
        uiElements.passwordSecondTimeTextfield.delegate = self
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

    // MARK: - OBJC methods -
    // Реализация тапа кнопки submitButton
    @objc private func submitButtonTapped() {
        viewModel.input.presentTabBarController()
    }

    // Реализация тапа кнопки changeStateButton
    @objc private func changeStateButtonTapped() {
        viewModel.input.cleanTextfields() // отчищаются текстфилды
        viewModel.input.changeViewControllerState()
        // переключаем состояние контроллера между авторизацией и регистрацией
        viewModel.input.disableSubmitButton() // Отключаем submitButton
    }

    @objc private func textfieldTextDidChange() {
        let nameTextFieldText = uiElements.nameTextField.text as String
        let passwordTestFieldText = uiElements.passwordTestField.text as String
        let passwordSecondTimeTextfieldText = uiElements.passwordSecondTimeTextfield.text as String

        /* Проверяются поля для того, чтобы активировать кнопку submitButton или нет
         А также включает/выключает лейбл, говорящий о том, что пароли при регистрации не совпадают */
        self.viewModel.input.checkTextfields(
            name: nameTextFieldText,
            password: passwordTestFieldText,
            secondPassword: passwordSecondTimeTextfieldText)
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
            node.transitionLayout(withAnimation: true, shouldMeasureAsync: false)
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        if isKeyboardShown {
            isKeyboardShown = false
            keyboardHeight = 0
            node.transitionLayout(withAnimation: true, shouldMeasureAsync: false)
        }
    }
}

// MARK: - extension + UITextFieldDelegate
extension RegisterViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Если кнопка submitButton активна, перекидываем на tabBarController
        switch viewModel.output.submitButtonState.value {
        case .enable:
            viewModel.input.presentTabBarController()
        case .disable:
            /*
            Если кнопка submitButton не активна, определяем, какой текстфилд сделать респондером
            (пример: выбираем 3 текстфилд, кликаем в клавиатуре continue,
            респондером сделается тот филд, который самый верхний и не заполненный)
             */
            let nameTF = uiElements.nameTextField
            let passwordTF = uiElements.passwordTestField
            let secondPasswordTF = uiElements.passwordSecondTimeTextfield

            viewModel.input
                .becomeFirstResponderOrClearOffTextfields(nameTextField: nameTF,
                                                          passwordTestField: passwordTF,
                                                          passwordSecondTimeTextfield: secondPasswordTF,
                                                          presenter: self)
        }
        return true
    }
}
