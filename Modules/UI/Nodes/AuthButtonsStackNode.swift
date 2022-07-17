//
//  AuthButtonsNode.swift
//  MyChat
//
//  Created by Boris Verbitsky on 07.04.2022.
//

import AsyncDisplayKit
import UIKit

private enum LocalConstants {
    static let googleImage   = UIImage(named: "google")
    static let appleImage    = UIImage(named: "apple")
    static let facebookImage = UIImage(named: "facebook")
}

public final class AuthButtonsStackNode: ASDisplayNode {

    // MARK: Public properties
    public private(set) lazy var googleButton   = AuthButtonNode(image: LocalConstants.googleImage ?? UIImage())
    public private(set) lazy var appleButton    = AuthButtonNode(image: LocalConstants.appleImage ?? UIImage())
    public private(set) lazy var facebookButton = AuthButtonNode(image: LocalConstants.facebookImage ?? UIImage())

    // MARK: Init
    public override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }

    // MARK: Override methods
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

        let buttons = [googleButton, appleButton, facebookButton]
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
