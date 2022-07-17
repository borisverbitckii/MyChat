//
//  textFieldCellNode.swift
//  UI
//
//  Created by Boris Verbitsky on 12.06.2022.
//

import Models
import AsyncDisplayKit

private enum LocalConstants {
    /// Textfield
    static let textfieldCornerRadius: CGFloat = 8
    static let containerInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

    static let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
}

public final class TextFieldCellNode: ASCellNode {

    // MARK: Public properties
    public lazy var textField: ASTextFieldNode = {
        let textfield = ASTextFieldNode()
        textfield.cornerRadius = LocalConstants.textfieldCornerRadius
        textfield.clipsToBounds = true
        textfield.textContainerInset = LocalConstants.containerInsets
        textfield.textField.addTarget(self, action: #selector(textfieldDidChange), for: .editingChanged)
        return textfield
    }()

    // MARK: Private properties
    private let userInfoClosure: (String) -> ()

    // MARK: Init
    public init(model: ProfileCellModel,
                userInfoClosure: @escaping (String) -> ()) {
        self.userInfoClosure = userInfoClosure
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = .clear
        textField.backgroundColor = model.textfieldBackgroundColor
    }

    // MARK: Override methods
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let insetsSpec = ASInsetLayoutSpec(insets: LocalConstants.insets, child: textField)
        return insetsSpec
    }

    // MARK: Public Methods
    public func configure(userName: String,
                          placeholder: String,
                          font: UIFont) {
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        textField.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                             attributes: attributes)
        textField.font = font
        textField.text = userName
    }

    // MARK: Private methods
    @objc private func textfieldDidChange() {
        userInfoClosure(textField.text)
    }
}
