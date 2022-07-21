//
//  ChatViewController.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UI
import RxSwift
import AsyncDisplayKit
import CoreData

private enum LocalConstants {
    static let sendButtonIsNotEnableAlpha: CGFloat = 0.5
}

final class ChatViewController: ASDKViewController<ASDisplayNode> {

    // MARK: - Private properties
    private let viewModel: ChatViewModelProtocol
    private let uiElements: ChatUI
    private lazy var bag = DisposeBag()

    private lazy var navBarTitle = ""
    private var navBarItem: UINavigationItem?

    private var topInset: CGFloat = 0
    private let bottomSafeAreaInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom
    private lazy var bottomInset = bottomSafeAreaInset

    // MARK: - Init
    init(uiElements: ChatUI,
         chatViewModel: ChatViewModelProtocol) {
        self.uiElements = uiElements
        self.viewModel = chatViewModel

        let node = ASDisplayNode()
        super.init(node: node)
        node.automaticallyManagesSubnodes = true
        node.layoutSpecBlock = layout()
        uiElements.messagesCollectionNode.dataSource = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.input.checkIsUserOnline(presenter: self)
        setupNavigationBar()
        setupToolBar()
        addSubviews()
        setupCollectionViewGesture()
        bindUIElements()
        subscribeToViewModel()
        addKeyboardObservers()
        viewModel.output.fetchResultsController?.delegate = self
        viewModel.input.setupSender()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topInset = (navigationController?.navigationBar.frame.height ?? 0) + uiElements.statusBarView.frame.height
        node.transitionLayout(withAnimation: false, shouldMeasureAsync: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isToolbarHidden = true
        navBarItem?.title = navBarTitle
    }

    // MARK: Private methods
    private func layout() -> ASLayoutSpecBlock {
        { [weak self] _, _ in
            guard let self = self else { return ASLayoutSpec() }
            self.uiElements.messagesCollectionNode.style.flexShrink = 1
            self.uiElements.messagesCollectionNode.style.flexGrow = 1
            let stack = ASStackLayoutSpec()
            stack.direction = .vertical
            stack.children = [self.uiElements.messagesCollectionNode, self.uiElements.toolBar]
            let insets = UIEdgeInsets(top: self.topInset,
                                      left: 0,
                                      bottom: self.bottomInset ?? 0,
                                      right: 0)
            let insetsSpec = ASInsetLayoutSpec(insets: insets, child: stack)
            return insetsSpec
        }
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.items?.forEach { item in
            if item.title == navigationController?.title {
                navBarItem = item
                navBarTitle = navigationController?.title ?? ""
                item.title = ""
            }
        }
        navigationItem.titleView = setupUserView()
    }

    private func setupUserView() -> UIView {
        let view = UIView()
        uiElements.userNameLabel.font = viewModel.output.userNameFont
        view.addSubview(uiElements.userIcon)
        view.addSubview(uiElements.userNameLabel)

        if let barHeight = navigationController?.navigationBar.frame.height {
            uiElements.userIcon.center.y = barHeight / 2
            let userNameLabelX = uiElements.userIcon.frame.origin.x + uiElements.userIcon.frame.width + 6
            uiElements.userNameLabel.frame = CGRect(x: userNameLabelX,
                                                    y: 0,
                                                    width: 0,
                                                    height: 0)
        }

        view.frame.size = CGSize(width: navigationController?.navigationBar.frame.width ?? 0,
                                 height: navigationController?.navigationBar.frame.height ?? 0)
        return view
    }

    private func setupToolBar() {
        uiElements.toolBar.sendMessageButton.addTarget(self, action: #selector(send), forControlEvents: .touchUpInside)
        viewModel.output.sendButtonColor
            .subscribe { [uiElements] event in
                uiElements.toolBar.sendMessageButton.tintColor = event.element
            }
            .disposed(by: bag)

        uiElements.toolBar.messageTextFieldNode.delegate = self
        uiElements.toolBar.messageTextFieldNode.textField.addTarget(self,
                                                                    action: #selector(textFieldTextDidChange(sender:)),
                                                                    for: .editingChanged)

        let placeholder = viewModel.output.toolBarPlaceholder
        let font = viewModel.output.toolBarPlaceholderFont
        let attributes = [NSAttributedString.Key.font: font]
        uiElements.toolBar.messageTextFieldNode.textField.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                                                                     attributes: attributes)
        uiElements.toolBar.messageTextFieldNode.font = font

        viewModel.output.textfieldBackgroundColor
            .subscribe { [uiElements] event in
                uiElements.toolBar.messageTextFieldNode.backgroundColor = event.element
            }
            .disposed(by: bag)
    }

    private func addSubviews() {
        node?.view.addSubview(uiElements.statusBarView)
    }

    private func setupCollectionViewGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        uiElements.messagesCollectionNode.view.addGestureRecognizer(gesture)
    }

    private func bindUIElements() {
        viewModel.output.viewControllerBackgroundColor
            .subscribe { [weak node, weak uiElements] event in
                node?.backgroundColor = event.element
                uiElements?.statusBarView.backgroundColor = event.element
                uiElements?.messagesCollectionNode.backgroundColor = event.element
            }
            .disposed(by: bag)

        viewModel.output.receiverUserIcon
            .subscribe { [weak uiElements] event in
                guard let image = event.element else { return }
                uiElements?.userIcon.image = image
            }
            .disposed(by: bag)

        viewModel.output.receiverUserName
            .subscribe { [weak self, weak uiElements] event in
                uiElements?.userNameLabel.text = event.element
                uiElements?.userNameLabel.sizeToFit()
                uiElements?.userNameLabel.center.y = (self?.navigationController?.navigationBar.frame.height ?? 0) / 2
            }
            .disposed(by: bag)
    }

    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
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
        uiElements.toolBar.sendMessageButton.isEnabled = false
        uiElements.toolBar.sendMessageButton.alpha = LocalConstants.sendButtonIsNotEnableAlpha
        uiElements.messagesCollectionNode.scrollToItem(at: IndexPath(item: 0, section: 0),
                                                       at: .bottom,
                                                       animated: true)

        let messageText = uiElements.toolBar.messageTextFieldNode.text
        uiElements.toolBar.messageTextFieldNode.text = ""
        viewModel.input.sendMessage(with: messageText)
    }

    @objc private func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            bottomInset = keyboardSize.height
            node.transitionLayout(withAnimation: true, shouldMeasureAsync: false)
        }
    }

    @objc private func keyboardWillHide() {
        bottomInset = bottomSafeAreaInset
        node.transitionLayout(withAnimation: true, shouldMeasureAsync: false)
    }

    @objc private func textFieldTextDidChange(sender: UITextField) {
        uiElements.toolBar.sendMessageButton.isEnabled = sender.text == ""
        ? false
        : true

        uiElements.toolBar.sendMessageButton.alpha = sender.text == ""
        ? LocalConstants.sendButtonIsNotEnableAlpha
        : 1
    }

    @objc private func tapped() {
        uiElements.textfieldForToolbar.resignFirstResponder()
    }
}

// MARK: - extension + ASCollectionDataSource -
extension ChatViewController: ASCollectionDataSource, ASCollectionDelegate {

    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = viewModel.output.fetchResultsController?.sections?[section]
        return sectionInfo?.numberOfObjects ?? 0
    }

    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        guard let message = viewModel.output.fetchResultsController?.object(at: indexPath) else {
            return {
                ASCellNode()
            }
        }

        let cell = MessageCellNode()
        let model = viewModel.output.getCellModel()
        cell.configureCell(with: message, model: model)
        return {
            cell
        }
    }
}

// MARK: - extension + NSFetchedResultsControllerDelegate -
extension ChatViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        DispatchQueue.main.async {
            switch type {
            case .insert:
                guard let newIndexPath = newIndexPath else { return }
                self.uiElements.messagesCollectionNode.insertItems(at: [newIndexPath])
            case .delete:
                guard let indexPath = indexPath else { return }
                self.uiElements.messagesCollectionNode.deleteItems(at: [indexPath])
            case .move:
                guard let indexPath = indexPath,
                      let newIndexPath = newIndexPath else { return }
                self.uiElements.messagesCollectionNode.moveItem(at: [indexPath.item], to: [newIndexPath.item])
            case .update:
                guard let indexPath = indexPath else { return }
                self.uiElements.messagesCollectionNode.reloadItems(at: [indexPath])
            @unknown default:
                break
            }
        }
    }
}

// MARK: - extension + UITextFieldDelegate -
extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
