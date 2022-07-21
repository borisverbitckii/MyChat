//
//  RegisterUIElements.swift
//  MyChat
//
//  Created by Boris Verbitsky on 28.03.2022.
//

import UI
import AsyncDisplayKit

private enum LocalConstants {
    static let cornerRadius: CGFloat = 8
}

final class RegisterUI {

    // MARK: Public properties
    private(set) lazy var orLabel = ASTextNode()
    private(set) lazy var errorLabel = ASTextNode()
    private(set) lazy var authButtons = AuthButtonsStackNode()
    private(set) lazy var agreementButton = ASButtonNode()
    private(set) lazy var politicButton = ASButtonNode()

    private(set) lazy var activityIndicator: ActivityIndicatorNode = {
        $0.alpha = 0
        $0.isHidden = true
        return $0
    }(ActivityIndicatorNode())

    private(set) lazy var submitButton: ASButtonNode = {
        let button = ASButtonNode()
        button.cornerRadius = LocalConstants.cornerRadius
        button.clipsToBounds = true
        return button
    }()

    private(set) lazy var changeStateButton: ASButtonNode = {
        let button = ASButtonNode()
        button.cornerRadius = LocalConstants.cornerRadius
        button.clipsToBounds = true
        return button
    }()

    private(set) lazy var nameTextField: TextFieldWithBottomBorderNode = {
        $0.textfield.autocorrectionType = .no
        $0.textfield.returnKeyType = .continue
        $0.automaticallyManagesSubnodes = true
        $0.textfield.autocapitalizationType = .none
        return $0
    }(TextFieldWithBottomBorderNode())

    private(set) lazy var passwordTestField: TextFieldWithBottomBorderNode = {
        $0.textfield.autocorrectionType = .no
        $0.textfield.returnKeyType = .continue
        $0.automaticallyManagesSubnodes = true
        $0.textfield.autocapitalizationType = .none
        $0.textfield.textField.clearButtonMode = .whileEditing
        return $0
    }(TextFieldWithBottomBorderNode())

    private(set) lazy var passwordSecondTimeTextfield: TextFieldWithBottomBorderNode = {
        $0.textfield.autocorrectionType = .no
        $0.textfield.returnKeyType = .continue
        $0.automaticallyManagesSubnodes = true
        $0.textfield.autocapitalizationType = .none
        $0.textfield.textField.clearButtonMode = .whileEditing
        return $0
    }(TextFieldWithBottomBorderNode())
}
