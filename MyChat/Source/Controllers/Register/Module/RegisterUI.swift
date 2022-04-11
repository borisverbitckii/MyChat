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
    let passwordsErrorLabel = ASTextNode()
    let orLabel = ASTextNode()
    let submitButton = ASButtonNode()
    let changeStateButton = ASButtonNode()

    let nameTextField: TextFieldWithBottomBorderNode = {
        $0.textfield.autocorrectionType = .no
        $0.textfield.autocapitalizationType = .none
        $0.textfield.returnKeyType = .continue
        $0.automaticallyManagesSubnodes = true
        return $0
    }(TextFieldWithBottomBorderNode())

    let passwordTestField: TextFieldWithBottomBorderNode = {
        $0.textfield.autocorrectionType = .no
        $0.textfield.autocapitalizationType = .none
        $0.textfield.returnKeyType = .continue
        $0.automaticallyManagesSubnodes = true
        return $0
    }(TextFieldWithBottomBorderNode())

    let passwordSecondTimeTextfield: TextFieldWithBottomBorderNode = {
        $0.textfield.autocorrectionType = .no
        $0.textfield.autocapitalizationType = .none
        $0.textfield.returnKeyType = .continue
        $0.automaticallyManagesSubnodes = true
        return $0
    }(TextFieldWithBottomBorderNode())

    let authButtons: AuthButtonsNode = {
        $0.automaticallyManagesSubnodes = true
        return $0
    }(AuthButtonsNode())

    // MARK: Private Properties
    private let palette: (RegisterViewControllerPalette) -> UIColor // удаленная установка цветов

    // MARK: Init
    init(palette: @escaping (RegisterViewControllerPalette) -> (UIColor)) {
        self.palette = palette
        changeStateButton.tintColor = palette(.changeStateButtonColor)
        submitButton.tintColor = palette(.submitButtonTextColor)

        [nameTextField,
         passwordTestField,
         passwordSecondTimeTextfield]
            .forEach { $0.backgroundColor = palette(.textFieldBackgroundColor) }
    }
}
