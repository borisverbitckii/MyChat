//
//  ViewControllers.swift
//  MyChat
//
//  Created by Boris Verbitsky on 07.04.2022.
//

/*
 Набор перечислений для всех ресурсов контроллеров:
 - Шрифты для всех ui элементов
 - Тексты для всех ui элементов
 - Цвета для всех ui элементов
 */

// MARK: - RegisterViewController -
enum RegisterViewControllerTexts: String {
    case namePlaceholder
    case passwordPlaceholder
    case secondPasswordPlaceholder
    case authTextForButton
    case sighUpTextForButton
    // ErrorLabel
    case errorLabelPasswordsNotTheSame
    case errorLabelEmailInvalid
    case errorLabelPasswordInvalid
    // AlertController
    case alertControllerTitle
    case alertControllerAuthError
    case alertControllerGoogleAuthError
    case alertControllerAppleAuthError
    case alertControllerFacebookAuthError
    case alertControllerSignUpError
    case alertControllerInvalidEmail
    case alertControllerInvalidPassword
    case alertControllerIsAlreadySignUp
    case alertControllerOKAction
    case orLabelText
    case termsOfUse
    case privacyPolicy
}

enum RegisterViewControllerFonts: String {
    case submitButton
    case changeStateButton
    case registerTextfield
    case registerErrorLabel
    case registerOrLabel
    case agreements
}

enum RegisterViewControllerPalette: String {
    case viewControllerBackgroundColor
    case changeStateButtonColor
    case textfieldsPlaceholderColor
    case submitButtonTextColor
    case submitButtonDisableTintColor
    case submitButtonActiveTintColor
    case orLabelTextColor
    case authButtonBackground
    case errorLabelTextColor
    case agreementsTitleColor
}

// MARK: - ChatsListViewController -
enum ChatsListViewControllerTexts: String {
    case title
    case searchBarPlaceholder
    case deleteButtonTitle
    case alertTitle
    case alertMessage
    case alertActionTitle
    case noChatsText
    case noChatsFoundText
}

enum ChatsListViewControllerFonts: String {
    case emptyStateTitle
    case navBarTitle
    case searchTextfieldPlaceholder
    case cellMessageBaseFont
    case cellMessageUserFont
}

enum ChatsListViewControllerPalette: String {
    // swiftlint:disable:next identifier_name
    case chatsListViewControllerEmptyStateFontColor
    case chatsListViewControllerBackgroundColor
    case chatNameCellColor
}

// MARK: - SettingsViewController -
enum SettingsViewControllerTexts: String {
    case title
    case profileCellTitle
    case logOutCellTitle
}

enum SettingsViewControllerFonts: String {
    case cellTitle
}

enum SettingsViewControllerPalette: String {
    case settingsViewControllerBackgroundColor
    case settingsCellBackgroundColor
    case settingsCellFontColor
}

// MARK: - ProfileViewController -
enum ProfileViewControllerTexts: String {
    case uploadButtonText
    case nameTextfieldPlaceholder
    case saveButtonTitle
    case alertTitle
    case camera
    case library
    case alertNoNameTitle
    case alertNoNameMessage
    case alertOkAction
}

enum ProfileViewControllerFonts: String {
    case button
    case textfield
}

enum ProfileViewControllerPalette: String {
    case profileViewControllerBackgroundColor
    case textfieldBackgroundColor
}

// MARK: - NewChatViewController -
enum NewChatViewControllerTexts: String {
    case navBarTitle
    case searchBarPlaceholder
    case emptyStateText
}

enum NewChatViewControllerPalette: String {
    case newChatViewControllerBackgroundColor
    case searchBarTintColor
    case userNameCellColor
    case emptyStateTextColor
}

enum NewChatViewControllerFonts: String {
    case emptyStateText
    case navBarTitle
    case searchTextfieldPlaceholder
    case cancelButton
}

// MARK: - ChatViewController -

enum ChatViewControllerTexts: String {
    case alertTitle
    case alertMessage
    case alertActionTitle
    case toolBarPlaceholder
    case messagePlaceholder
}

enum ChatViewControllerPalette: String {
    case chatViewControllerBackgroundColor
    case chatViewControllerSendButtonColor
    // swiftlint:disable:next identifier_name
    case chatViewControllerTextFieldBackgroundColor
    case chatViewControllerMessageCellColor
}

enum ChatViewControllerFonts: String {
    case userName
    case messageText
    case time
    case toolBarPlaceholder
}
