//
//  ChatUI.swift
//  MyChat
//
//  Created by Boris Verbitsky on 28.04.2022.
//

import UI
import UIKit
import AsyncDisplayKit

private enum LocalConstants {
    /// MessagesCollectionNode
    static let collectionNodeTopInset: CGFloat = 8
    static let collectionNodeBottomInset: CGFloat = 8
    /// UserIcon
    static let userIconSize = CGSize(width: 30, height: 30)
    static let userIconCornerRadius: CGFloat = 15
    static let userIconTintColor = UIColor.lightGray.withAlphaComponent(0.4)
    /// UserNameLabel
    static let userNameLabelFontSize: CGFloat = 13

}

final class ChatUI {

    private(set) lazy var textfieldForToolbar: TextField = {
        $0.clipsToBounds = true
        $0.backgroundColor = .white
        return $0
    }(TextField())

    private(set) lazy var messagesCollectionNode: ASCollectionNode = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let collectionNode = ASCollectionNode(frame: .zero,
                                              collectionViewLayout: flowLayout)
        collectionNode.contentInset.top = LocalConstants.collectionNodeTopInset
        collectionNode.contentInset.bottom = LocalConstants.collectionNodeBottomInset

        collectionNode.view.keyboardDismissMode = .onDrag
        collectionNode.inverted = true
        return collectionNode
    }()

    private(set) lazy var statusBarView: UIView = {
        let window = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        let statusBarFrame = window?.windowScene?.statusBarManager?.statusBarFrame

        return UIView(frame: statusBarFrame!)
    }()

    private(set) lazy var userIcon: UIImageView = {
        $0.frame.size = LocalConstants.userIconSize
        $0.layer.cornerRadius = LocalConstants.userIconCornerRadius
        $0.clipsToBounds = true
        $0.tintColor = LocalConstants.userIconTintColor
        return $0
    }(UIImageView())

    private(set) lazy var userNameLabel: UILabel = {
        $0.font = UIFont.boldSystemFont(ofSize: LocalConstants.userNameLabelFontSize)
        return $0
    }(UILabel())

    private(set) lazy var toolBar = MessageToolBarNode()
}
