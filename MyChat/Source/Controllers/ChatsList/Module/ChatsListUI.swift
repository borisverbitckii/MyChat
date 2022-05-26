//
//  ChatsListUIElements.swift
//  MyChat
//
//  Created by Boris Verbitsky on 05.04.2022.
//

import UI
import AsyncDisplayKit

final class ChatsListUI {

    private (set) lazy var chatsTableNode: ASTableNode = {
        let tableNode = ASTableNode()
        tableNode.view.separatorStyle = .none
        tableNode.backgroundColor = .clear
        tableNode.style.flexBasis = ASDimension(unit: .fraction, value: 100)
        return tableNode
    }()

    private(set) lazy var searchBar = SearchBarNode()

}
