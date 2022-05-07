//
//  ViewController.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UI
import Logger
import RxSwift
import AsyncDisplayKit
import CoreData

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
        node.automaticallyManagesSubnodes = true

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
        subscribeToViewModel()
        setupDelegates()
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

    private func subscribeToViewModel() {
        viewModel.output.chatsCollectionShouldReload
            .subscribe { [uiElements] _ in
                uiElements.chatsCollectionView.reloadData()
            }
            .disposed(by: bag)
    }

    private func setupDelegates() {
        viewModel.output.fetchResultsController.delegate = self
    }

    // MARK: OBJC methods
    @objc private func addChat() {
        viewModel.input.createChatRoom(withChatAt: IndexPath(), presenterVC: self)
    }
}

// MARK: - ChatsListViewController + ASCollectionDataSource -
extension ChatsListViewController: ASCollectionDataSource {

    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return viewModel.input.getChatsCount(section: section)
    }

    func collectionNode(_ collectionNode: ASCollectionNode,
                        nodeBlockForItemAt
                        indexPath: IndexPath) -> ASCellNodeBlock {
        let chat = viewModel.output.chatForIndexPath(indexPath: indexPath)
        return {
            let cell = ChatCellNode()
            cell.configureWithChat(chat)
            return cell
        }
    }
}

// MARK: - ChatsListViewController + ASCollectionDelegate -
extension ChatsListViewController: ASCollectionDelegate {

    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        collectionNode.deselectItem(at: indexPath, animated: true)
        viewModel.input.createChatRoom(withChatAt: indexPath, presenterVC: self)
    }
}

// MARK: - extension + NSFetchedResultsControllerDelegate -
extension ChatsListViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        switch type {
        case .insert:
            uiElements.chatsCollectionView.insertItems(at: [indexPath])
        case .delete:
            uiElements.chatsCollectionView.deleteItems(at: [indexPath])
        case .move:
            guard let newIndexPath = newIndexPath else { return }
            uiElements.chatsCollectionView.moveItem(at: [indexPath.item], to: [newIndexPath.item])
        case .update:
            uiElements.chatsCollectionView.reloadItems(at: [indexPath])
        @unknown default:
            break
        }
    }
}
