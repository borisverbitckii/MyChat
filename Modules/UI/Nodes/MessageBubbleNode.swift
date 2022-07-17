//
//  MessageBubbleNode.swift
//  UI
//
//  Created by Boris Verbitsky on 08.06.2022.
//

import AsyncDisplayKit

private enum LocalConstants {
    static let cornerRadius: CGFloat = 10
    static let bubbleInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
}

public final class MessageBubbleNode: ASDisplayNode {

    // MARK: Public properties
    public lazy var textNode = ASTextNode()

    // MARK: Init
    public override init() {
        super.init()
        automaticallyManagesSubnodes = true
        cornerRadius = LocalConstants.cornerRadius
        clipsToBounds = true
        style.maxSize = CGSize(width: UIScreen.main.bounds.width / 3 * 2, height: 250)
    }

    // MARK: Override methods
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let insets = LocalConstants.bubbleInsets
        return ASInsetLayoutSpec(insets: insets, child: textNode)
    }

    public func setupBackgroundColor(with color: UIColor) {
        backgroundColor = color
    }
}
