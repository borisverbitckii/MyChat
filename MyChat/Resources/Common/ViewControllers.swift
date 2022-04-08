//
//  ViewControllers.swift
//  MyChat
//
//  Created by Boris Verbitsky on 07.04.2022.
//

enum ViewControllers {
    case registerViewController
    case chatsListViewController
    case profileViewController
    case newChatViewController
}

// MARK: - RegisterViewController -
enum RegisterViewControllerTexts: String {
    case namePlaceholder
    case passwordPlaceholder
    case secondPasswordPlaceholder
    case authTextForButton
    case sighUpTextForButton
    case errorPasswordLabel
    // AlertController
    case alertControllerTitle
    case alertControllerAuthError
    case alertControllerSignUpError
    case alertControllerOKAction
    case orLabelText
}

enum RegisterViewControllerFonts: String {
    case submitButton
    case changeStateButton
    case registerTextfield
    case registerErrorLabel
    case registerOrLabel
}

enum RegisterViewControllerPalette: String {
    case viewControllerBackgroundColor
    case changeStateButtonColor
    case textFieldBackgroundColor
    case submitButtonTextColor
    case submitButtonDisableTintColor
    case submitButtonActiveTintColor

}

// MARK: - ChatsListViewController -
enum ChatsListViewControllerTexts: String {
    case title
}

enum ChatsListViewControllerFonts: String {
    case empty
}

enum ChatsListViewControllerPalette: String {
    case empty
}

// MARK: - ProfileViewController -
enum ProfileViewControllerTexts: String {
    case title
}

enum ProfileViewControllerFonts: String {
    case empty
}

enum ProfileViewControllerPalette: String {
    case empty
}
