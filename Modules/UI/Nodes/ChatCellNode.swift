//
//  ChatCellNode.swift
//  MyChat
//
//  Created by Boris Verbitsky on 05.04.2022.
//

import AsyncDisplayKit
import Models

private enum ChatCellLocalConstants {
    static let size = CGSize(width: 80, height: 80)
    static let userIconHorizontalInset: CGFloat = 16
}

public final class ChatCellNode: ASCellNode {

    // MARK: Private Properties
    private var chat: Chat?

        // UIElements
    private let title: ASTextNode = {
        $0.placeholderEnabled = true
        return $0
    }(ASTextNode())

    private let userIcon: ASNetworkImageNode = {
        $0.defaultImage = nil // TODO: Заменить на дефолтную картинку
        $0.placeholderEnabled = true // TODO: Проверить duration
        $0.clipsToBounds = true
        return $0
    }(ASNetworkImageNode())

    private let messageTime: ASTextNode = {
        $0.placeholderEnabled = true
        return $0
    }(ASTextNode())

    private let messageText: ASTextNode = {
        $0.placeholderEnabled = true
        return $0
    }(ASTextNode())

    // MARK: Public methods
    public func configureWithChat(_ chat: Chat) {
        self.chat = chat
        userIcon.url = URL(string: chat.contact.userIcon)
    }

    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        super.layoutSpecThatFits(constrainedSize)

        // userIcon
        let positionSpec = ASRelativeLayoutSpec(horizontalPosition: .start,
                                        verticalPosition: .center,
                                        sizingOption: [], child: self)

        let iconInset = UIEdgeInsets(top: 0,
                                     left: ChatCellLocalConstants.userIconHorizontalInset,
                                     bottom: 0,
                                     right: ChatCellLocalConstants.userIconHorizontalInset)

        let iconInsetSpec = ASInsetLayoutSpec(insets: iconInset,
                                              child: positionSpec)

        // Стек для заголовка

        // Сообщение

        // Вертикальный стек для заголовка + сообщения

        // Финальный горизонтальный стек
        let finalHorizontalStack = ASStackLayoutSpec()

        let finalHorizontalStackInsets = UIEdgeInsets(top: 8,
                                                      left: 16,
                                                      bottom: 8,
                                                      right: 16)

        let finalHorizontalStackInsetsSpec = ASInsetLayoutSpec(insets: finalHorizontalStackInsets,
                                                               child: finalHorizontalStack)

        return finalHorizontalStackInsetsSpec
    }
}
