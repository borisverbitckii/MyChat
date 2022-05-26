//
//  ContactUserCellNode.swift
//  UI
//
//  Created by Boris Verbitsky on 21.05.2022.
//

import Models
import AsyncDisplayKit
import Darwin

public struct ContactUserCellModel {
    let userNameColor: UIColor

    public init(userNameColor: UIColor) {
        self.userNameColor = userNameColor
    }
}

private enum LocalConstants {
    static let imageSize = CGSize(width: 40, height: 40)
    static let vStackInsets = UIEdgeInsets(top: 8,
                                           left: 16,
                                           bottom: 8,
                                           right: 16)
    static let vStackSpacing: CGFloat = 2
    static let hStackInsets = UIEdgeInsets(top: 4,
                                           left: 16,
                                           bottom: 4,
                                           right: 16)
    static let placeholderImageTintColor = UIColor.lightGray.withAlphaComponent(0.4)

    static let nameFont = UIFont.boldSystemFont(ofSize: 12)
    static let emailColor = UIColor(hue: 0.6, saturation: 0.84, brightness: 0.92, alpha: 1)
}

public final class ContactUserCellNode: ASCellNode {

    // UI
    private lazy var userImageNode: UserImageNode = {
        let imageNode = UserImageNode()
        imageNode.shouldCacheImage = true

        imageNode.contentMode = .scaleAspectFill
        imageNode.placeholderEnabled = true
        imageNode.tintColor = LocalConstants.placeholderImageTintColor

        imageNode.style.preferredSize = LocalConstants.imageSize
        imageNode.cornerRadius = imageNode.style.preferredSize.height / 2
        imageNode.clipsToBounds = true
        return imageNode
    }()
    private lazy var userNameLabel: ASTextNode = {
        let userNameLabel = ASTextNode()
        return userNameLabel
    }()

    private lazy var userEmailLabel: ASTextNode = {
        let emailLabel = ASTextNode()
        return emailLabel
    }()

    // MARK: Init
    public init(user: ChatUser, cellModel: ContactUserCellModel) {
        super.init()
        automaticallyManagesSubnodes = true
        if user.avatarURL?.absoluteString != nil {
            userImageNode.url = user.avatarURL
        } else {
            userImageNode.image = userImageNode.placeholderImage()
        }

        let nameAttributes = [NSAttributedString.Key.font: LocalConstants.nameFont,
                              NSAttributedString.Key.foregroundColor: cellModel.userNameColor]
        userNameLabel.attributedText = NSAttributedString(string: user.name ?? "-", attributes: nameAttributes)
        let emailAttributes = [NSAttributedString.Key.foregroundColor: LocalConstants.emailColor]
        userEmailLabel.attributedText = NSAttributedString(string: user.email ?? "", attributes: emailAttributes)

        backgroundColor = .clear
    }

    // MARK: Public Methods
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let vStack = ASStackLayoutSpec()
        vStack.direction = .vertical
        vStack.horizontalAlignment = .left
        vStack.verticalAlignment = .center
        vStack.children = [userNameLabel, userEmailLabel]
        vStack.spacing = LocalConstants.vStackSpacing

        let vStackInsets = LocalConstants.vStackInsets
        let vStackInsetsSpec = ASInsetLayoutSpec(insets: vStackInsets, child: vStack)

        let hStack = ASStackLayoutSpec()
        hStack.direction = .horizontal
        hStack.children = [userImageNode, vStackInsetsSpec]

        let centerHStackSpec = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: [], child: hStack)

        let hStackInsets = LocalConstants.hStackInsets
        let hStackInsetsSpec = ASInsetLayoutSpec(insets: hStackInsets, child: centerHStackSpec)
        return hStackInsetsSpec
    }
}
