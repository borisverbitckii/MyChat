//
//  ChatViewController.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UI
import RxSwift
import AsyncDisplayKit

final class ChatViewController: ASDKViewController<ASDisplayNode> {

    // MARK: - Private properties
    private let viewModel: ChatViewModelProtocol
    private let uiElements: ChatUI
    private lazy var bag = DisposeBag()

    // MARK: - Init
    init(uiElements: ChatUI,
         chatViewModel: ChatViewModelProtocol) {
        self.uiElements = uiElements
        self.viewModel = chatViewModel

        let node = ASDisplayNode()
        super.init(node: node)
        node.automaticallyManagesSubnodes = true
        node.layoutSpecBlock = { _, _ in // TODO: Исправить
            ASWrapperLayoutSpec(layoutElement: uiElements.messagesCollectionNode)
        }

        uiElements.messagesCollectionNode.dataSource = self
        uiElements.messagesCollectionNode.delegate = self

        uiElements.messagesCollectionNode.inverted = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        node.backgroundColor = .white
        tabBarController?.tabBar.isHidden = true
        hidesBottomBarWhenPushed = true
        setupToolBar()
        subscribeToViewModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.isToolbarHidden = true
    }

    // MARK: Private methods
    private func setupToolBar() {
        navigationController?.isToolbarHidden = false
        navigationController?.toolbar.backgroundColor = .gray

        var toolbarItems = [UIBarButtonItem]()

        let textfield = uiElements.textfieldForToolbar
        textfield.frame.size = CGSize(width: UIScreen.main.bounds.width - 70, height: 40) // TODO: Исправить и перенести
        let textfieldBarButtonItem = UIBarButtonItem(customView: textfield)
        toolbarItems.append(textfieldBarButtonItem)

        let sendBarButtonItem =  UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(send))
        toolbarItems.append(sendBarButtonItem)

        self.toolbarItems = toolbarItems
    }

    private func subscribeToViewModel() {
        viewModel.output.messageCollectionViewShouldReload
            .subscribe { [weak self] _ in
                self?.uiElements.messagesCollectionNode.reloadData()
            }
            .disposed(by: bag)
    }

    // MARK: Objc private methods
    @objc private func send() {
        guard let messageText = uiElements.textfieldForToolbar.text else { return }
        uiElements.textfieldForToolbar.text = ""
        viewModel.input.sendMessage(with: messageText)
    }
}

// MARK: - extension + ASCollectionDataSource -
extension ChatViewController: ASCollectionDataSource {

    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        viewModel.input.getMessagesCount()
    }

    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let message = viewModel.input.getMessage(for: indexPath.row)
        return {
            let cell = MessageCellNode()
            cell.configureCell(with: message)
            return cell
        }
    }
}

// MARK: - extension + ASCollectionDelegate -
extension ChatViewController: ASCollectionDelegate {

}
