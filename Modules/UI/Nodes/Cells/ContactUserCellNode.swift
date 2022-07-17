//
//  ContactUserCellNode.swift
//  UI
//
//  Created by Boris Verbitsky on 21.05.2022.
//

import UIKit
import Models
import AsyncDisplayKit

public protocol ContactUserCellNodeDelegate: AnyObject {
    func setupUserImage(with image: UIImage?)
}

private enum LocalConstants {
    static let defaultImage = UIImage(named: "userImagePlaceholder")?.withRenderingMode(.alwaysTemplate)
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

    // MARK: Private properties
    /// UI
    private lazy var userImageNode: ASImageNode = {
        let imageNode = ASImageNode()
        imageNode.image = LocalConstants.defaultImage

        imageNode.contentMode = .scaleAspectFill
        imageNode.tintColor = LocalConstants.placeholderImageTintColor

        imageNode.style.preferredSize = LocalConstants.imageSize
        imageNode.cornerRadius = imageNode.style.preferredSize.height / 2
        imageNode.clipsToBounds = true
        return imageNode
    }()
    private lazy var userNameLabel = ASTextNode()
    private lazy var userEmailLabel = ASTextNode()

    // MARK: Init
    public init(model: ContactCellModel) {
        super.init()
        automaticallyManagesSubnodes = true
        let nameAttributes = [NSAttributedString.Key.font: LocalConstants.nameFont,
                              NSAttributedString.Key.foregroundColor: model.nameColor]
        let emailAttributes = [NSAttributedString.Key.foregroundColor: LocalConstants.emailColor]
        userNameLabel.attributedText = NSAttributedString(string: model.name, attributes: nameAttributes)
        userEmailLabel.attributedText = NSAttributedString(string: model.email,
                                                           attributes: emailAttributes)
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

// MARK: - extension + ContactUserCellNodeDelegate -
extension ContactUserCellNode: ContactUserCellNodeDelegate {
    public func setupUserImage(with image: UIImage?) {
        guard let image = image else { return }
        userImageNode.image = image
    }
}
