//
//  ChatsListUIElements.swift
//  MyChat
//
//  Created by Boris Verbitsky on 05.04.2022.
//

import AsyncDisplayKit

final class ChatsListUI {

    let chatsCollectionView: ASCollectionNode = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        return ASCollectionNode(frame: .zero, collectionViewLayout: flowLayout)
    }()
}
