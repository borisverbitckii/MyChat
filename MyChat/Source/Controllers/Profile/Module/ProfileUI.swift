//
//  ProfileUI.swift
//  MyChat
//
//  Created by Boris Verbitsky on 10.06.2022.
//

import UI
import AsyncDisplayKit

final class ProfileUI {

    private(set) lazy var tableNode: ASTableNode = {
        let tableNode = ASTableNode()
        tableNode.view.isScrollEnabled = false
        tableNode.style.flexShrink = 1
        tableNode.style.flexGrow = 1
        tableNode.allowsSelection = false
        tableNode.view.separatorStyle = .none
        return tableNode
    }()
}
