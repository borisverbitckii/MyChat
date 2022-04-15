//
//  RegisterUIElements.swift
//  MyChat
//
//  Created by Boris Verbitsky on 28.03.2022.
//

import AsyncDisplayKit
import UI

final class RegisterUI {

    // MARK: Public properties
    lazy var orLabel = ASTextNode()
    lazy var errorLabel = ASTextNode()
    lazy var submitButton = ASButtonNode()
    lazy var changeStateButton = ASButtonNode()
    lazy var authButtons = AuthButtonsStackNode()

    lazy var nameTextField: TextFieldWithBottomBorderNode = {
        $0.textfield.autocorrectionType = .no
        $0.textfield.returnKeyType = .continue
        $0.automaticallyManagesSubnodes = true
        $0.textfield.autocapitalizationType = .none
        return $0
    }(TextFieldWithBottomBorderNode())

    lazy var passwordTestField: TextFieldWithBottomBorderNode = {
        $0.textfield.autocorrectionType = .no
        $0.textfield.returnKeyType = .continue
        $0.automaticallyManagesSubnodes = true
        $0.textfield.autocapitalizationType = .none
        $0.textfield.textField.clearButtonMode = .whileEditing
        return $0
    }(TextFieldWithBottomBorderNode())

    lazy var passwordSecondTimeTextfield: TextFieldWithBottomBorderNode = {
        $0.textfield.autocorrectionType = .no
        $0.textfield.returnKeyType = .continue
        $0.automaticallyManagesSubnodes = true
        $0.textfield.autocapitalizationType = .none
        $0.textfield.textField.clearButtonMode = .whileEditing
        return $0
    }(TextFieldWithBottomBorderNode())

    // MARK: Init
    init(palette: @escaping (RegisterViewControllerPalette) -> (UIColor)) {
        changeStateButton.tintColor = palette(.changeStateButtonColor)
        submitButton.tintColor = palette(.submitButtonTextColor)

        [nameTextField,
         passwordTestField,
         passwordSecondTimeTextfield]
            .forEach { $0.backgroundColor = palette(.textFieldBackgroundColor) }

        authButtons.configureBackground(withColor: palette(.authButtonBackground))
    }
}
