//
//  ChatUI.swift
//  MyChat
//
//  Created by Boris Verbitsky on 28.04.2022.
//

import AsyncDisplayKit

final class ChatUI {

    lazy var textfieldForToolbar = UITextField()

    lazy var messagesCollectionNode: ASCollectionNode = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let collectionNode = ASCollectionNode(frame: .zero, collectionViewLayout: flowLayout)
        return collectionNode
    }()
}
