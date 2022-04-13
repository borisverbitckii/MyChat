//
//  ViewController.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import AsyncDisplayKit
import RxSwift

final class ChatsListViewController: ASDKViewController<ASCollectionNode> {

    // MARK: Private properties
    private let uiElements: ChatsListUI
    private let viewModel: ChatsListViewModelProtocol
    private let bag = DisposeBag()

    // MARK: Init
    init(uiElements: ChatsListUI,
         chatsListViewModel: ChatsListViewModelProtocol) {
        self.uiElements = uiElements
        self.viewModel = chatsListViewModel
        let node = uiElements.chatsCollectionView
        super.init(node: node)
        node.delegate = self
        node.dataSource = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        node.backgroundColor = .white
        setupNavigationBar()
        bindUIElements()
    }

    // MARK: Private methods
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addChat))
    }

    private func bindUIElements() {
        viewModel.output.titleText
            .subscribe { [weak self] event in
                self?.title = event.element
            }
            .disposed(by: bag)

        viewModel.output.viewControllerBackgroundColor
            .subscribe { [weak view] event in
                view?.backgroundColor = event.element
            }
            .disposed(by: bag)
    }

    // MARK: OBJC methods
    @objc private func addChat() {
        print("add chat")
    }
}

// MARK: - ChatsListViewController + ASCollectionDataSource -
extension ChatsListViewController: ASCollectionDataSource {

    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return viewModel.output.chatsCount
    }

    func collectionNode(_ collectionNode: ASCollectionNode,
                        nodeBlockForItemAt
                        indexPath: IndexPath) -> ASCellNodeBlock {
        let chat = viewModel.output.chatForIndexPath(index: indexPath.item)
        return {
            let cell = ChatCellNode()
            cell.configureWithChat(chat)
            return cell
        }
    }
}

// MARK: - ChatsListViewController + ASCollectionDelegate -
extension ChatsListViewController: ASCollectionDelegate {

}
