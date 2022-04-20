//
//  ChatViewController.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import AsyncDisplayKit

final class ChatViewController: ASDKViewController<ASDisplayNode> {

    // MARK: - Private properties
    private let chatViewModel: ChatViewModelProtocol

    // UIElements
    private let messagesCollectionView: UICollectionView = {
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()))

    // MARK: - Init
    init(chatViewModel: ChatViewModelProtocol) {
        self.chatViewModel = chatViewModel
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
