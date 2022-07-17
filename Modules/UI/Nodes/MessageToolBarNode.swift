//
//  ToolBarNode.swift
//  UI
//
//  Created by Boris Verbitsky on 07.06.2022.
//

import AsyncDisplayKit

public final class MessageToolBarNode: ASDisplayNode {

    // MARK: Public properties
    public let messageTextFieldNode: ASTextFieldNode = {
        let textfield = ASTextFieldNode()
        textfield.textContainerInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        textfield.style.preferredSize = CGSize(width: UIScreen.main.bounds.width - 90,
                                               height: 30)
        textfield.cornerRadius = textfield.style.preferredSize.height / 2
        textfield.clipsToBounds = true
        textfield.borderWidth = 1
        textfield.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        return textfield
    }()

    public let sendMessageButton: ASButtonNode = {
        let button = ASButtonNode()
        button.style.preferredSize = CGSize(width: 30, height: 30)
        button.cornerRadius = 15

        let buttonImage = UIImage(named: "sendMessage")?.withRenderingMode(.alwaysTemplate)
        button.setImage(buttonImage, for: .normal)
        button.imageNode.contentMode = .scaleAspectFit

        button.alpha = 0.5
        return button
    }()

    public override var style: ASLayoutElementStyle {
        let style = super.style
        style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 49)
        return style
    }

    // MARK: Init
    public override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }

    // MARK: Override methods
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stack = ASStackLayoutSpec()
        stack.direction = .horizontal
        stack.children = [messageTextFieldNode, sendMessageButton]
        stack.spacing = 10
        stack.alignItems = .center
        stack.justifyContent = .center
        return stack
    }
}
