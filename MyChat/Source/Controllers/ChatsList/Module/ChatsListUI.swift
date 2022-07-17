//
//  ChatsListUIElements.swift
//  MyChat
//
//  Created by Boris Verbitsky on 05.04.2022.
//

import UI
import AsyncDisplayKit

private enum LocalConstants {
    static let tableNodeFlexBasics: CGFloat = 100
}

final class ChatsListUI {

    private (set) lazy var chatsTableNode: TableNodeWithEmptyState = {
        let tableNode = TableNodeWithEmptyState()
        tableNode.backgroundColor = .clear
        tableNode.style.flexBasis = ASDimension(unit: .fraction,
                                                value: LocalConstants.tableNodeFlexBasics)
        return tableNode
    }()

    private(set) lazy var searchBar = SearchBarNode()

}
