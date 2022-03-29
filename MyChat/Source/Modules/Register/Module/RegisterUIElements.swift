//
//  RegisterUIElements.swift
//  MyChat
//
//  Created by Boris Verbitsky on 28.03.2022.
//

import UIKit

final class RegisterUIElements {
    // MARK: - Public methods -
    let titleLabel: UILabel = {
        return $0
    }(UILabel())

    let passwordsErrorLabel: UILabel = {
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
        $0.isSecureTextEntry = true
        return $0
    }(UITextField())

    let passwordSecondTimeTextfield: UITextField = {
        $0.placeholder = Text.textfield(.password(.second)).text
        $0.backgroundColor = .white
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.returnKeyType = .continue
        $0.textContentType = .password
        $0.isSecureTextEntry = true
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
