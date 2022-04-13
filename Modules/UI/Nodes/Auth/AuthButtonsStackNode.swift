//
//  AuthButtonsNode.swift
//  MyChat
//
//  Created by Boris Verbitsky on 07.04.2022.
//

import AsyncDisplayKit
import UIKit

public final class AuthButtonsStackNode: ASDisplayNode {

    public lazy var googleButton: AuthButtonNode = {
        let image = ASImageNode()
        image.image = UIImage(named: "google")
        return AuthButtonNode(image: image)
    }()

    public lazy var facebookButton: AuthButtonNode = {
        let image = ASImageNode()
        image.image = UIImage(named: "facebook")
        return AuthButtonNode(image: image)
    }()

    // MARK: Ovveride methods
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

        let buttons = [googleButton, facebookButton]
        buttons.forEach { $0.style.preferredSize = CGSize(width: 100, height: 40)}

        let hStack = ASStackLayoutSpec(direction: .horizontal,
                                       spacing: 10,
                                       justifyContent: .center,
                                       alignItems: .center,
                                       children: buttons)
        return hStack
    }

    public func configureBackground(withColor color: UIColor) {
        googleButton.backgroundColor = color
        facebookButton.backgroundColor = color
    }
}
