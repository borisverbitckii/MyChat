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
    static var maxTopInset: CGFloat = 44
    static var minTopInset: CGFloat = 10
    static let cellHeight: CGFloat = 65
    static let searchBarHeight: CGFloat = 35
    static let settingsImage = UIImage(named: "setting")
    static let settingImageWidth: CGFloat = 21
    static let settingImageHeight: CGFloat = 21
}

final class ChatsListViewController: ASDKViewController<ASDisplayNode> {

    // MARK: Private properties
    private let uiElements: ChatsListUI
    private let viewModel: ChatsListViewModelProtocol
    private lazy var bag = DisposeBag()

    /// Отступ для того, чтобы показывать или не показывать navigationBar
    private var topInset: CGFloat = 0
    private var searchingProcessIsActive = false {
        didSet {
            if searchingProcessIsActive == false {
                uiElements.chatsTableNode.reloadData()
            }
        }
    }

    // MARK: Init
    init(uiElements: ChatsListUI,
         chatsListViewModel: ChatsListViewModelProtocol) {
        self.uiElements = uiElements
        self.viewModel = chatsListViewModel
        let node = ASDisplayNode()
        super.init(node: node)
        node.automaticallyManagesSubnodes = true
        node.layoutSpecBlock = layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.input.viewDidLoad()
        setupNavigationBar()
        setupSearchBar()
        bindUIElements()
        subscribeToViewModel()
        setupDelegates()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let statusBarHeight = node.view.window?.safeAreaInsets.top ?? 0
        let navBarHeight = navigationController?.navigationBar.frame.height ?? 0
        let inset = statusBarHeight + navBarHeight
        /// Верстка для того, чтобы показывать или не показывать navigationBar
        if !searchingProcessIsActive {
            LocalConstants.maxTopInset = inset
            topInset = inset
            node.transitionLayout(withAnimation: false, shouldMeasureAsync: false)
        } else {
            LocalConstants.minTopInset = statusBarHeight
            topInset = statusBarHeight
            node.transitionLayout(withAnimation: false, shouldMeasureAsync: false)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        uiElements.chatsTableNode.reloadData()
    }

    // MARK: Private methods
    private func setupNavigationBar() {
        /// Шрифт для заголовка и кнопки назад
        let app = UINavigationBarAppearance()
        let attributes = [NSAttributedString.Key.font: viewModel.output.navBarTitleFont]
        app.titleTextAttributes = attributes
        app.backButtonAppearance.normal.titleTextAttributes = attributes
        navigationController?.navigationBar.standardAppearance = app

        /// Кнопки для navigationBar
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                 target: self,
                                                 action: #selector(addChat))

        navigationItem.rightBarButtonItem = rightBarButtonItem

        let button = UIButton(type: .system)
        button.setImage(LocalConstants.settingsImage,
                        for: .normal)
        button.addTarget(self,
                         action: #selector(pushSettingsViewController),
                         for: .touchUpInside)

        let leftBarButtonItem = UIBarButtonItem(customView: button)

        leftBarButtonItem
            .customView?
            .widthAnchor
            .constraint(equalToConstant: LocalConstants.settingImageWidth)
            .isActive = true

        leftBarButtonItem
            .customView?
            .heightAnchor
            .constraint(equalToConstant: LocalConstants.settingImageHeight)
            .isActive = true
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }

    private func setupSearchBar() {
        guard let width = navigationController?.view.bounds.size.width else { return }
        uiElements.searchBar.font = viewModel.output.searchFont
        uiElements.searchBar.frame = CGRect(x: 0,
                                            y: 0,
                                            width: width,
                                            height: LocalConstants.searchBarHeight)
        uiElements.searchBar.backgroundImage = UIImage()
        uiElements.searchBar.addTarget(target: self,
                                       action: #selector(searchTextfieldDidChange(sender:)),
                                       for: .editingChanged)
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
            .subscribe { [weak uiElements, viewModel] event in
                guard let placeholder = event.element else { return }
                let attributes = [NSAttributedString.Key.font: viewModel.output.searchFont]
                uiElements?.searchBar.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                                                 attributes: attributes)
            }
            .disposed(by: bag)
    }

    private func subscribeToViewModel() {
        viewModel.output.chatsCollectionShouldReload
            .subscribe { [weak uiElements] _ in
                uiElements?.chatsTableNode.reloadData()
            }
            .disposed(by: bag)

        viewModel.output.showAlert
            .subscribe { [viewModel] _ in
                viewModel.input.presentAlertController(presenter: self)
            }
            .disposed(by: bag)
    }

    private func setupDelegates() {
        viewModel.output.fetchResultsController.delegate = self
        uiElements.chatsTableNode.delegate = self
        uiElements.chatsTableNode.dataSource = self
        uiElements.searchBar.setDelegate(with: self)
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

    @objc private func pushSettingsViewController() {
        viewModel.input.pushSettingsViewController(presenterVC: self)
    }

    @objc private func searchTextfieldDidChange(sender: UITextField) {
        guard let name = sender.text, name != "" else { return }
        viewModel.input.filterUsers(with: name)
    }
}

// MARK: - ChatsListViewController + ASTableDataSource -
extension ChatsListViewController: ASTableDataSource {

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = viewModel.output.fetchResultsController.sections?[section]

        /// Заставка, когда активен поиск
        if searchingProcessIsActive && sectionInfo?.numberOfObjects == 0 {
            uiElements.chatsTableNode.setupState(with: .noChatsFound)
            uiElements.chatsTableNode.setupText(with: viewModel.output.noChatsFoundText,
                                                font: viewModel.output.noChatsFoundFont,
                                                fontColor: viewModel.output.noChatsFoundColor.value)
            return sectionInfo?.numberOfObjects ?? 0
        }

        /// Заставка, когда нет ни одного чата
        if sectionInfo?.numberOfObjects == 0 {
            uiElements.chatsTableNode.setupState(with: .noChats)
            uiElements.chatsTableNode.setupText(with: viewModel.output.noChatsText,
                                                font: viewModel.output.noChatFont,
                                                fontColor: viewModel.output.noChatsFontColor.value)
            return sectionInfo?.numberOfObjects ?? 0
        }
        uiElements.chatsTableNode.setupState(with: .normal)
        return sectionInfo?.numberOfObjects ?? 0
    }

    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let model = viewModel.output.getChatCellModel(for: indexPath)
        let cell = ChatCellNode()
        viewModel.input.setupChatCellNodeDelegate(with: cell, indexPath: indexPath)
        guard let model = model else { return { cell } }
        cell.configure(model: model)
        return { cell }
    }

    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        let width = uiElements.chatsTableNode.frame.width
        let size = CGSize(width: width,
                          height: LocalConstants.cellHeight)
        return ASSizeRange(min: size, max: size)
    }
}

// MARK: - ChatsListViewController + ASTableDelegate -
extension ChatsListViewController: ASTableDelegate {

    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        uiElements.chatsTableNode.deselectRow(at: indexPath, animated: true)
        viewModel.input.pushChatViewController(chat: indexPath, presenterVC: self)
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive,
                                        title: viewModel.output.removeActionTitle) { [weak self, bag] _, _, _ in
            self?.viewModel.input.removeChat(at: indexPath)
                .subscribe()
                .disposed(by: bag)
        }
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
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
            case .update:
                guard let indexPath = indexPath else { return }
                self.uiElements.chatsTableNode.reloadRows(at: [indexPath], with: .automatic)
            case .move:
                guard let indexPath = indexPath,
                      let newIndexPath = newIndexPath else { return }
                self.uiElements.chatsTableNode.moveRow(at: indexPath, to: newIndexPath)
            @unknown default:
                break
            }
        }
    }
}

// MARK: - extension + UISearchBarDelegate -
extension ChatsListViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchingProcessIsActive = true
        searchBar.setShowsCancelButton(true, animated: true)
        topInset = LocalConstants.minTopInset
        node.transitionLayout(withAnimation: true, shouldMeasureAsync: false)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        viewModel.input.setupDefaultChatList()
        searchingProcessIsActive = false
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
