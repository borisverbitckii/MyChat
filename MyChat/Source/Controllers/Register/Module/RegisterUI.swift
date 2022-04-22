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
    lazy var activityIndicator: ActivityIndicatorNode = {
        $0.alpha = 0
        $0.isHidden = true
        return $0
    }(ActivityIndicatorNode())

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
}
