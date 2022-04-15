//
//  AuthButtonsNode.swift
//  MyChat
//
//  Created by Boris Verbitsky on 07.04.2022.
//

import AsyncDisplayKit
import UIKit

public final class AuthButtonsStackNode: ASDisplayNode {

    // MARK: Public properties
    public lazy var googleButton: AuthButtonNode = {
        let image = ASImageNode()
        image.image = UIImage(named: "google")
        return AuthButtonNode(image: image)
    }()

    public lazy var appleButton: AuthButtonNode = {
        let image = ASImageNode()
        image.image = UIImage(named: "apple")
        return AuthButtonNode(image: image)
    }()

    public lazy var facebookButton: AuthButtonNode = {
        let image = ASImageNode()
        image.image = UIImage(named: "facebook")
        return AuthButtonNode(image: image)
    }()

    // MARK: Init
    public override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }

    // MARK: Override methods
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

        let buttons = [googleButton, appleButton , facebookButton]
        buttons.forEach { $0.style.preferredSize = CGSize(width: 80, height: 40)}

        let hStack = ASStackLayoutSpec(direction: .horizontal,
                                       spacing: 10,
                                       justifyContent: .center,
                                       alignItems: .center,
                                       children: buttons)
        return hStack
    }

    public func configureBackground(withColor color: UIColor) {
        [googleButton, appleButton, facebookButton].forEach { $0.backgroundColor = color}
    }
}
