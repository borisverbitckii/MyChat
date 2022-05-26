//
//  NewChatViewController.swift
//  MyChat
//
//  Created by Борис on 14.02.2022.
//

import UI
import UIKit
import RxSwift
import AsyncDisplayKit

final class NewChatViewController: ASDKViewController<ASDisplayNode> {

    // MARK: Private properties
    private let viewModel: NewChatViewModelProtocol
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

        uiElements.contactsTableNode.dataSource = self
        uiElements.contactsTableNode.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        node.backgroundColor = UIColor(named: "splashViewControllerBackgroundColor")
        setupNavigationBar()
        setupSearchBar()
        bindUIElements()
    }

    // MARK: Private methods
    private func setupNavigationBar() {
        let dismissButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissVC))
        uiElements.navigationItem.leftBarButtonItem = dismissButton
        uiElements.navBarNode.setItems(with: [uiElements.navigationItem], animated: false)
    }

    private func setupSearchBar() {
        uiElements.searchBarNode.setDelegate(with: self)
        uiElements.searchBarNode.addTarget(target: self,
                                           action: #selector(searchTextfieldDidChange(sender:)),
                                           for: .editingChanged)
    }

    private func bindUIElements() {
        viewModel.output.navBarTitle
            .subscribe { [weak uiElements] event in
                guard let title = event.element else { return }
                uiElements?.navigationItem.title = title
            }
            .disposed(by: bag)

        viewModel.output.searchBarPlaceholder
            .subscribe { [weak uiElements] event in
                guard let placeholder = event.element else { return }
                uiElements?.searchBarNode.placeholder = placeholder
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
        viewModel.output.getUsersCount()
    }

    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let user = viewModel.output.getUser(at: indexPath.row)
        return { [viewModel] in
            ContactUserCellNode(user: user, cellModel: viewModel.output.cellModel)
        }
    }
}

// MARK: - extension + ASTableDelegate -
extension NewChatViewController: ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        let size = CGSize(width: uiElements.contactsTableNode.frame.width, height: 50)
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
