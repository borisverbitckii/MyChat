//
//  MessageCellNode.swift
//  UI
//
//  Created by Boris Verbitsky on 29.04.2022.
//

import Models
import AsyncDisplayKit
import Foundation

private enum LocalConstants {
    static let bubbleInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    static let stackSpacing: CGFloat = 10
    static let textAndTimeColor = UIColor.white.withAlphaComponent(0.8)
}

public final class MessageCellNode: ASCellNode {

    // MARK: Private properties
    private lazy var bubble = MessageBubbleNode()
    private lazy var messageTimeNode = ASTextNode()

    private var messagePosition: MessagePosition?

    // MARK: Init
    public override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }

    // MARK: Override methods
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

        var insets = LocalConstants.bubbleInsets

        let horizontalStack = ASStackLayoutSpec()
        horizontalStack.direction = .horizontal
        horizontalStack.children = [bubble, messageTimeNode]
        horizontalStack.spacing = LocalConstants.stackSpacing
        horizontalStack.alignItems = .center

        switch messagePosition {
        case .left:
            horizontalStack.children = [bubble, messageTimeNode]
            insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 80)
        case .right:
            horizontalStack.justifyContent = .end
            horizontalStack.children = [messageTimeNode, bubble]
            insets = UIEdgeInsets(top: 0, left: 80, bottom: 0, right: 16)
        default: break
        }
        return ASInsetLayoutSpec(insets: insets, child: horizontalStack)
    }

    // MARK: Public Methods
    public func configureCell(with message: CDMessage, model: MessageCellModel) {
        self.messagePosition = message.position

        // Бабл сообщения
        let messageText = message.text ?? ""
        let stringHeight = messageText.size().height
        style.minSize = CGSize(width: UIScreen.main.bounds.width, height: stringHeight + 10)
        style.maxSize = CGSize(width: UIScreen.main.bounds.width, height: 250)

        var attributes = [NSAttributedString.Key: Any]()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        attributes[NSAttributedString.Key.foregroundColor] = LocalConstants.textAndTimeColor
        attributes[NSAttributedString.Key.font] = model.baseFont
        bubble.textNode.attributedText = NSAttributedString(string: messageText, attributes: attributes)
        bubble.setupBackgroundColor(with: model.messageBubleBackgroundColor)

        // Время
        if let timeInterval = TimeInterval(message.date) {
            let date = Date(timeIntervalSince1970: timeInterval)
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let time = formatter.string(from: date)
            let attributes = [
                NSAttributedString.Key.foregroundColor: UIColor.systemGray,
                NSAttributedString.Key.font: model.timeFont
            ]
            messageTimeNode.attributedText = NSAttributedString(string: time, attributes: attributes)
        }
    }
}
