//
//  NewChatViewController.swift
//  MyChat
//
//  Created by Борис on 14.02.2022.
//

import UI
import UIKit
import RxSwift
import CoreData
import AsyncDisplayKit

private enum LocalConstants {
    static let cellHeight: CGFloat = 50
}

final class NewChatViewController: ASDKViewController<ASDisplayNode> {

    // MARK: Private properties
    private var viewModel: NewChatViewModelProtocol
    private let uiElements: NewChatUI
    private lazy var bag = DisposeBag()

    // MARK: Init
    init(newChatViewModel: NewChatViewModelProtocol, uiElements: NewChatUI) {
        self.viewModel = newChatViewModel
        self.uiElements = uiElements
        let node = ASDisplayNode()
        super.init(node: node)
        node.layoutSpecBlock = layout()
        node.automaticallyManagesSubnodes = true
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
        setupDelegates()
    }

    // MARK: Private methods
    private func setupNavigationBar() {
        let dismissButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissVC))
        dismissButton.setTitleTextAttributes([NSAttributedString.Key.font: viewModel.output.cancelButtonFont],
                                             for: .normal)
        uiElements.navigationItem.leftBarButtonItem = dismissButton
        uiElements.navBarNode.setItems(with: [uiElements.navigationItem], animated: false)
        uiElements.navBarNode.titleTextAttributes = [NSAttributedString.Key.font: viewModel.output.navBarTitleFont]
    }

    private func setupSearchBar() {
        uiElements.searchBarNode.font = viewModel.output.searchFont
        uiElements.searchBarNode.addTarget(target: self,
                                           action: #selector(searchTextfieldDidChange(sender:)),
                                           for: .editingChanged)
    }

    private func bindUIElements() {
        viewModel.output.viewControllerBackgroundColor
            .subscribe { [weak node] event in
                guard let backgroundColor = event.element else { return }
                node?.backgroundColor = backgroundColor
            }
            .disposed(by: bag)

        viewModel.output.navBarTitle
            .subscribe { [weak uiElements] event in
                guard let title = event.element else { return }
                uiElements?.navigationItem.title = title
            }
            .disposed(by: bag)

        viewModel.output.searchBarPlaceholder
            .subscribe { [weak uiElements, viewModel] event in
                guard let placeholder = event.element else { return }

                let attributes = [NSAttributedString.Key.font: viewModel.output.searchFont]
                uiElements?.searchBarNode.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                                                 attributes: attributes)
            }
            .disposed(by: bag)

        viewModel.output.reloadCollectionNode
            .subscribe { [weak uiElements] _ in
                uiElements?.contactsTableNode.reloadSections([0], with: .fade)
            }
            .disposed(by: bag)

        viewModel.output.searchBarTintColor
            .subscribe { [weak uiElements] event in
                guard let color = event.element else { return }
                uiElements?.searchBarNode.barTintColor = color
            }
            .disposed(by: bag)

    }

    private func setupDelegates() {
        uiElements.contactsTableNode.dataSource = self
        uiElements.contactsTableNode.delegate = self
        uiElements.searchBarNode.setDelegate(with: self)
    }

    private func layout() -> ASLayoutSpecBlock {
        { [uiElements] _, _ in
            let stackChildren = [uiElements.navBarNode,
                                 uiElements.searchBarNode,
                                 uiElements.contactsTableNode]
            let vStack = ASStackLayoutSpec()
            vStack.direction = .vertical
            vStack.children = stackChildren
            return vStack
        }
    }

    // MARK: Objc private methods
    @objc private func dismissVC() {
        dismiss(animated: true)
    }

    @objc private func searchTextfieldDidChange(sender: UITextField) {
        guard let name = sender.text, name != "" else { return }
        viewModel.input.fetchUsers(with: name)
    }
}

// MARK: - extension + ASCollectionDataSource -
extension NewChatViewController: ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        let usersCount = viewModel.output.getUsersCount()

        /// Заставка для пустого состояния
        if usersCount == 0 {
            uiElements.contactsTableNode.setupState(with: .startUserSearching)
            uiElements.contactsTableNode.setupText(with: viewModel.output.emptyStateTitleText,
                                                   font: viewModel.output.emptyStateTitleFont,
                                                   fontColor: viewModel.output.emptyStateTitleColor)
            return usersCount
        }

        uiElements.contactsTableNode.setupState(with: .normal)
        return usersCount
    }

    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let model = viewModel.output.getModel(at: indexPath.row)
        let cell = ContactUserCellNode(model: model)
        viewModel.input.setupCellDelegate(with: cell)
        viewModel.input.setupUserIcon(at: indexPath.row)
        return { cell }
    }
}

// MARK: - extension + ASTableDelegate -
extension NewChatViewController: ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        let size = CGSize(width: uiElements.contactsTableNode.frame.width,
                          height: LocalConstants.cellHeight)
        return ASSizeRange(min: size, max: size)
    }

    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        tableNode.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true) { [viewModel] in
            viewModel.input.presentChatViewController(userAt: indexPath.row)
        }
    }
}

// MARK: - extension + UISearchBarDelegate -
extension NewChatViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
    }
}

// MARK: - extension + NSFetchedResultsControllerDelegate -
extension NewChatViewController: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        DispatchQueue.main.async {
            switch type {
            case .insert:
                guard let newIndexPath = newIndexPath else { return }
                self.uiElements.contactsTableNode.insertRows(at: [newIndexPath], with: .automatic)
            case .delete:
                guard let indexPath = indexPath else { return }
                self.uiElements.contactsTableNode.deleteRows(at: [indexPath], with: .automatic)
            case .move:
                guard let indexPath = indexPath,
                      let newIndexPath = newIndexPath else { return }
                self.uiElements.contactsTableNode.moveRow(at: [indexPath.item], to: [newIndexPath.item])
            case .update:
                guard let indexPath = indexPath else { return }
                self.uiElements.contactsTableNode.reloadRows(at: [indexPath], with: .automatic)
            @unknown default:
                break
            }
        }
    }
}
