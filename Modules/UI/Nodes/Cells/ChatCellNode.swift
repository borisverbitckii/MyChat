//
//  ChatCellNode.swift
//  MyChat
//
//  Created by Boris Verbitsky on 05.04.2022.
//

import Models
import AsyncDisplayKit
import UIKit

private enum LocalConstants {
    static let defaultImage = UIImage(named: "userImagePlaceholder")?.withRenderingMode(.alwaysTemplate)
    static let imageSize = CGSize(width: 40, height: 40)
    static let imageTintColor = UIColor.lightGray.withAlphaComponent(0.4)
    static let vStackSpacing: CGFloat = 1
    static let hStackSpacing: CGFloat = 10
    static let hStackInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
}

public protocol ChatCellNodeDelegate: AnyObject {
    func setupUser(with user: CDChatUser, color: UIColor, font: UIFont)
    func setupChatIcon(with image: UIImage?)
}

public final class ChatCellNode: ASCellNode {

    // MARK: Private Properties
        // UIElements
    private lazy var userIconNode: ASImageNode = {
        $0.image = LocalConstants.defaultImage

        $0.contentMode = .scaleAspectFill
        $0.tintColor = LocalConstants.imageTintColor

        $0.style.preferredSize = LocalConstants.imageSize
        $0.cornerRadius = $0.style.preferredSize.height / 2
        $0.clipsToBounds = true
        return $0
    }(ASImageNode())

    private lazy var userNameLabelNode = ASTextNode()
    private lazy var messageTimeNode = ASTextNode()
    private lazy var messageTextNode: ASTextNode = {
        let node = ASTextNode()
        node.maximumNumberOfLines = 2
        return node
    }()

    // MARK: Init
    public override init() {
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = .clear
    }

    // MARK: Override methods
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

        let vStack = ASStackLayoutSpec()
        vStack.direction = .vertical
        vStack.children = [userNameLabelNode, messageTextNode]
        vStack.spacing = LocalConstants.vStackSpacing
        vStack.style.flexGrow = 1
        vStack.style.flexShrink = 1

        let hStack = ASStackLayoutSpec()
        hStack.direction = .horizontal
        hStack.spacing = LocalConstants.hStackSpacing
        hStack.alignItems = .center
        hStack.children = [userIconNode, vStack, messageTimeNode]
        messageTimeNode.style.alignSelf = .start

        let hStackInsets = LocalConstants.hStackInsets
        let hStackInsetsSpec = ASInsetLayoutSpec(insets: hStackInsets, child: hStack)

        return hStackInsetsSpec
    }

    // MARK: Public methods
    public func configure(model: ChatCellModel) {
        let messageText = model.messageText
        let messageTime = model.messageDate

        var time: String?

        if let timeInterval = TimeInterval(messageTime) {
            let date = Date(timeIntervalSince1970: timeInterval)
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            time = formatter.string(from: date)
        }

        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.gray,
                          NSAttributedString.Key.font: model.baseFont]
        self.messageTextNode.attributedText = NSAttributedString(string: messageText,
                                                                 attributes: attributes)
        self.messageTimeNode.attributedText = NSAttributedString(string: time ?? "00:00",
                                                                 attributes: attributes)

    }
}

// MARK: - extension +  -
extension ChatCellNode: ChatCellNodeDelegate {
    public func setupUser(with user: CDChatUser, color: UIColor, font: UIFont) {
        let attributes = [NSAttributedString.Key.font: font,
                          NSAttributedString.Key.foregroundColor: color]
        self.userNameLabelNode.attributedText = NSAttributedString(string: user.name, attributes: attributes)
    }

    public func setupChatIcon(with image: UIImage?) {
        guard let image = image else { return }
        userIconNode.image = image
    }
}
