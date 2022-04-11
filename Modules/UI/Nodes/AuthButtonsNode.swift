//
//  AuthButtonsNode.swift
//  MyChat
//
//  Created by Boris Verbitsky on 07.04.2022.
//

import AsyncDisplayKit

public final class AuthButtonsNode: ASDisplayNode {

    public let googleButton = ASButtonNode()
    public let facebookButton = ASButtonNode()

    // MARK: Ovveride methods
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

        let buttons = [googleButton, facebookButton]
        buttons.forEach { $0.backgroundColor = .gray.withAlphaComponent(0.15) }
        buttons.forEach { $0.style.preferredSize = CGSize(width: 100, height: 40)}

        let hStack = ASStackLayoutSpec(direction: .horizontal,
                                       spacing: 10,
                                       justifyContent: .center,
                                       alignItems: .center,
                                       children: buttons)
        return hStack
    }
}
