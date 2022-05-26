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
import UIKit

private enum LocalConstants {
    static let maxTopInset: CGFloat = 44
    static let minTopInset: CGFloat = 10

}

final class ChatsListViewController: ASDKViewController<ASDisplayNode> {

    // MARK: Private properties
    private let uiElements: ChatsListUI
    private let viewModel: ChatsListViewModelProtocol
    private let bag = DisposeBag()

    private var topInset: CGFloat = LocalConstants.maxTopInset

    // Настройка удаления по свайпу
    private var contextualActionHandler: UIContextualAction.Handler?
    private lazy var swipeActionConfiguration: UISwipeActionsConfiguration? = {
        guard let contextualActionHandler = contextualActionHandler else { return nil }
        let action = UIContextualAction(style: .destructive, title: "", handler: contextualActionHandler)
        viewModel.output.deleteButtonTitle
            .subscribe { event in
                action.title = event.element
            }
            .disposed(by: bag)
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }()

    // MARK: Init
    init(uiElements: ChatsListUI,
         chatsListViewModel: ChatsListViewModelProtocol) {
        self.uiElements = uiElements
        self.viewModel = chatsListViewModel
        let node = ASDisplayNode()
        super.init(node: node)
        node.automaticallyManagesSubnodes = true
        node.layoutSpecBlock = layout()

        uiElements.chatsTableNode.delegate = self
        uiElements.chatsTableNode.dataSource = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSearchBar()
        bindUIElements()
        subscribeToViewModel()
        setupDelegates()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        uiElements.chatsTableNode.reloadData()
    }

    // MARK: Private methods
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addChat))
    }

    private func setupSearchBar() {
        guard let width = navigationController?.view.bounds.size.width else { return }
        uiElements.searchBar.frame = CGRect(x: 0, y: 0, width: width, height: 35)
        uiElements.searchBar.backgroundImage = UIImage()
        uiElements.searchBar.setDelegate(with: self)
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

        viewModel.output.searchPlaceholder
            .subscribe { [weak uiElements] event in
                guard let placeholder = event.element else { return }
                uiElements?.searchBar.placeholder = placeholder
            }
            .disposed(by: bag)
    }

    private func subscribeToViewModel() {
        viewModel.output.chatsCollectionShouldReload
            .subscribe { [uiElements] _ in
                uiElements.chatsTableNode.reloadData()
            }
            .disposed(by: bag)
    }

    private func setupDelegates() {
        viewModel.output.fetchResultsController.delegate = self
    }

    private func layout() -> ASLayoutSpecBlock {
        { [weak self, uiElements] _, _ in
            let vStack = ASStackLayoutSpec()
            vStack.direction = .vertical
            vStack.children = [uiElements.searchBar,
                               uiElements.chatsTableNode]

            let inset = UIEdgeInsets(top: self?.topInset ?? 0,
                                     left: 0,
                                     bottom: 0,
                                     right: 0)
            let insetSpec = ASInsetLayoutSpec(insets: inset, child: vStack)
            return insetSpec
        }
    }

    // MARK: OBJC methods
    @objc private func addChat() {
        viewModel.input.presentNewChatViewController(presenterVC: self)
    }
}

// MARK: - ChatsListViewController + ASTableDataSource -
extension ChatsListViewController: ASTableDataSource {

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = viewModel.output.fetchResultsController.sections?[section]
        return sectionInfo?.numberOfObjects ?? 0
    }

    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let chat = viewModel.output.fetchResultsController.object(at: indexPath)
        return {
            let cell = ChatCellNode()
            cell.configureWithChat(chat)
            return cell
        }
    }
}

// MARK: - ChatsListViewController + ASTableDelegate -
extension ChatsListViewController: ASTableDelegate {

    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        uiElements.chatsTableNode.deselectRow(at: indexPath, animated: true)
        viewModel.input.pushChatViewController(chat: indexPath, presenterVC: self)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        contextualActionHandler = { [weak self, bag] _, _, _ in
            self?.viewModel.input.removeChat(at: indexPath)
                .subscribe()
                .disposed(by: bag)
        }
        return swipeActionConfiguration
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
}

// MARK: - extension + NSFetchedResultsControllerDelegate -
extension ChatsListViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        DispatchQueue.main.async {
            switch type {
            case .insert:
                guard let newIndexPath = newIndexPath else { return }
                self.uiElements.chatsTableNode.insertRows(at: [newIndexPath], with: .automatic)
            case .delete:
                guard let indexPath = indexPath else { return }
                self.uiElements.chatsTableNode.deleteRows(at: [indexPath], with: .automatic)
            case .move:
                guard let indexPath = indexPath,
                      let newIndexPath = newIndexPath else { return }
                self.uiElements.chatsTableNode.moveRow(at: [indexPath.item], to: [newIndexPath.item])
            case .update:
                guard let indexPath = indexPath else { return }
                self.uiElements.chatsTableNode.reloadRows(at: [indexPath], with: .automatic)
            @unknown default:
                break
            }
        }
    }
}

// MARK: - extension + UISearchBarDelegate -
extension ChatsListViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        topInset = LocalConstants.minTopInset
        node.transitionLayout(withAnimation: true, shouldMeasureAsync: false)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        topInset = LocalConstants.maxTopInset
        node.transitionLayout(withAnimation: true, shouldMeasureAsync: false)
        navigationController?.setNavigationBarHidden(false, animated: true)
        return true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
    }
}
