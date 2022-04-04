//
//  RegisterUIElements.swift
//  MyChat
//
//  Created by Boris Verbitsky on 28.03.2022.
//

import AsyncDisplayKit

final class RegisterUIElements {
    // MARK: - Public methods -
    let titleLabel: ASTextNode = {
        return $0
    }(ASTextNode())

    let passwordsErrorLabel: ASTextNode = {
        return $0
    }(ASTextNode())

    let nameTextField: ASTextFieldNode = {
        $0.backgroundColor = .white
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.returnKeyType = .continue
        return $0
    }(ASTextFieldNode())

    let passwordTestField: ASTextFieldNode = {
        $0.backgroundColor = .white
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.returnKeyType = .continue
        $0.isSecureTextEntry = true
        return $0
    }(ASTextFieldNode())

    let passwordSecondTimeTextfield: ASTextFieldNode = {
        $0.backgroundColor = .white
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.returnKeyType = .continue
        $0.isSecureTextEntry = true
        return $0
    }(ASTextFieldNode())

    let submitButton: ASButtonNode = {
        $0.backgroundColor = .red
        return $0
    }(ASButtonNode())

    let changeStateButton: ASButtonNode = {
        $0.backgroundColor = .gray
        return $0
    }(ASButtonNode())
}
