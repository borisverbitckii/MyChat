//
//  ASTextFieldNode.swift
//  UI
//
//  Created by Boris Verbitsky on 20.04.2022.
//

import AsyncDisplayKit

public final class ASTextFieldNode: ASDisplayNode, UITextInputTraits {

    // MARK: Public properties
    public var textField: ASTextFieldView
    public var textFieldNode: ASDisplayNode

    public var delegate: UITextFieldDelegate? {
        get {
            textField.delegate
        }

        set {
            textField.delegate = newValue
        }
    }

    public var placeholder: String? {
        get {
            textField.placeholder
        }
        set {
            textField.placeholder = newValue
        }
    }

    public var textContainerInset: UIEdgeInsets? {
        get {
            textField.textContainerInset
        }

        set {
            textField.textContainerInset = newValue
        }
    }

    public var font: UIFont? {
        get {
            textField.font
        }

        set {
            textField.font = newValue
        }
    }

    public var textColor: UIColor? {
        get {
            textField.textColor
        }
        set {
            textField.textColor = newValue
        }
    }

    public var text: String {
        get {
            textField.text ?? ""
        }
        set {
            textField.text = newValue
        }
    }

    public var setAttributedText: NSAttributedString? {
        get {
            textField.attributedText
        }
        set {
            textField.attributedText = newValue
        }
    }

    public var attributedPlaceholder: NSAttributedString? {
        get {
            textField.attributedPlaceholder
        }

        set {
            textField.attributedPlaceholder = newValue
        }
    }

    public var autocapitalizationType: UITextAutocapitalizationType {
        get {
            textField.autocapitalizationType
        }
        set {
            textField.autocapitalizationType = newValue
        }
    }

    public var autocorrectionType: UITextAutocorrectionType {
        get {
            textField.autocorrectionType
        }
        set {
            textField.autocorrectionType = newValue
        }
    }

    public var spellCheckingType: UITextSpellCheckingType {
        get {
            textField.spellCheckingType
        }
        set {
            textField.spellCheckingType = newValue
        }
    }

    public var keyboardType: UIKeyboardType {
        get {
            textField.keyboardType
        }
        set {
            textField.keyboardType = newValue
        }
    }

    public var keyboardAppearance: UIKeyboardAppearance {
        get {
            textField.keyboardAppearance
        }
        set {
            textField.keyboardAppearance = newValue
        }
    }

    public var returnKeyType: UIReturnKeyType {
        get {
            textField.returnKeyType
        }
        set {
            textField.returnKeyType = newValue
        }
    }

    public var enablesReturnKeyAutomatically: Bool {
        get {
            textField.enablesReturnKeyAutomatically
        }
        set {
            textField.enablesReturnKeyAutomatically = newValue
        }
    }

    public var isSecureTextEntry: Bool {
        get {
            textField.isSecureTextEntry
        }
        set {
            textField.isSecureTextEntry = newValue
        }
    }

    public var textContentType: UITextContentType {
        get {
            textField.textContentType
        }
        set {
            textField.textContentType = newValue
        }
    }

    public var lineHeight: CGFloat {
        guard let font = font else {
            return UIFont.systemFont(ofSize: 17).lineHeight
        }
        return font.lineHeight
    }

    // MARK: Init
    public override init() {
        let textfield = ASTextFieldView()
        textField = textfield
        textFieldNode = ASDisplayNode {
            return textfield
        }
        super.init()
        self.automaticallyManagesSubnodes = true
        self.style.height = ASDimension(unit: .points, value: 31)
    }

    // MARK: Public Methods
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let minWidth = ASDimension(unit: .points, value: constrainedSize.min.width)
        let minHeight = ASDimension(unit: .points, value: constrainedSize.min.height)
        let maxWidth = ASDimension(unit: .points, value: constrainedSize.max.width)
        let maxHeight = ASDimension(unit: .points, value: constrainedSize.max.height)

        let min = ASLayoutSize(width: minWidth, height: minHeight)
        let max = ASLayoutSize(width: maxWidth, height: maxHeight)

        let absoluteSpec = ASAbsoluteLayoutSpec()
        textFieldNode.style.minLayoutSize = min
        textFieldNode.style.maxLayoutSize = max
        textFieldNode.style.preferredLayoutSize = textFieldNode.style.maxLayoutSize
        absoluteSpec.children = [textFieldNode]
        return absoluteSpec
    }
}
