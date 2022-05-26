//
//  MessageCellNode.swift
//  UI
//
//  Created by Boris Verbitsky on 29.04.2022.
//

import Models
import AsyncDisplayKit

public final class MessageCellNode: ASCellNode {

    // MARK: Private properties
    private lazy var text: ASTextNode = ASTextNode()

    // MARK: Init
    public override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }

    // MARK: Override methods
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        ASWrapperLayoutSpec(layoutElement: text)
    }

    // MARK: Public Methods
    public func configureCell(with message: Message) {
        let messageText = message.text ?? ""
        let stringHeight = messageText.size().height
        text.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: stringHeight + 40)
        text.attributedText = NSAttributedString(string: messageText)
        backgroundColor = .red
    }
}
