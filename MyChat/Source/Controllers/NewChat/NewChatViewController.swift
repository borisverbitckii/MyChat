//
//  NewChatViewController.swift
//  MyChat
//
//  Created by Борис on 14.02.2022.
//

import AsyncDisplayKit

final class NewChatViewController: ASDKViewController<ASDisplayNode> {

    // MARK: - Private properties
    private let newChatViewModel: NewChatViewModelProtocol

    // MARK: - Init
    init(newChatViewModel: NewChatViewModelProtocol) {
        self.newChatViewModel = newChatViewModel
        super.init(node: ASDisplayNode())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
