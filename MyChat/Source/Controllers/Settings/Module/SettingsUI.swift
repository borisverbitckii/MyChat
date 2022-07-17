//
//  SettingsUI.swift
//  MyChat
//
//  Created by Boris Verbitsky on 30.06.2022.
//

import AsyncDisplayKit

public final class SettingsUI {

    public let tableViewNode: ASTableNode =  {
        let tableNode = ASTableNode()
        tableNode.view.isScrollEnabled = false
        tableNode.backgroundColor = .clear
        tableNode.view.separatorStyle = .none
        tableNode.backgroundColor = .red
        tableNode.cornerRadius = 8
        tableNode.clipsToBounds = true
        return tableNode
    }()
}
