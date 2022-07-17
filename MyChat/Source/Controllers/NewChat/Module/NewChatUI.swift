//
//  NewChatUI.swift
//  MyChat
//
//  Created by Boris Verbitsky on 20.05.2022.
//

import UI
import UIKit
import AsyncDisplayKit

final class NewChatUI {
    private(set) lazy var navBarNode: NavBarNode = {
        let navBarNode = NavBarNode()
        navBarNode.shadowImage = UIImage()
        return navBarNode
    }()
    private(set) lazy var navigationItem = UINavigationItem()
    private(set) lazy var searchBarNode: SearchBarNode = {
        let searchBarNode = SearchBarNode()
        searchBarNode.backgroundImage = UIImage()
        return searchBarNode
    }()
    private(set) lazy var contactsTableNode: TableNodeWithEmptyState = {
        let tableNode = TableNodeWithEmptyState()
        tableNode.view.separatorStyle = .none
        tableNode.backgroundColor = .clear
        tableNode.style.flexBasis = ASDimension(unit: .fraction, value: 100)
        tableNode.view.keyboardDismissMode = .onDrag
        return tableNode
    }()
}
