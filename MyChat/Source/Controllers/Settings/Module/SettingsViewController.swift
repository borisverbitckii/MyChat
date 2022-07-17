//
//  SettingsViewController.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UI
import RxSwift
import AsyncDisplayKit

private enum LocalConstants {
    static let cellHeight: CGFloat = 40
    static let tableViewInsets: (CGFloat, CGFloat) -> UIEdgeInsets = { topInset, bottomInset in
        UIEdgeInsets(top: topInset,
                     left: 16,
                     bottom: bottomInset,
                     right: 16)
    }
}

final class SettingsViewController: ASDKViewController<ASDisplayNode> {

    // MARK: Private properties
    private let viewModel: SettingsViewModelProtocol
    private let uiElements: SettingsUI
    private let bag = DisposeBag()

    // MARK: Init
    init(settingsViewModel: SettingsViewModelProtocol,
         uiElements: SettingsUI) {
        self.viewModel = settingsViewModel
        self.uiElements = uiElements
        let node = ASDisplayNode()
        node.automaticallyManagesSubnodes = true
        super.init(node: node)
        node.layoutSpecBlock = layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.input.viewDidLoad(presenter: self)
        setupDelegates()
        bindUIElements()
    }

    // MARK: Private methods
    private func layout() -> ASLayoutSpecBlock {
        { [weak self, uiElements] _, _ in
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            let navBarHeight = self?.navigationController?.navigationBar.frame.height ?? 0
            let topInset = statusBarHeight + navBarHeight + 16
            let bottomInset = UIScreen.main.bounds.height - topInset - 80
            return ASInsetLayoutSpec(insets: LocalConstants.tableViewInsets(topInset, bottomInset),
                              child: uiElements.tableViewNode)
        }
    }

    private func setupDelegates() {
        uiElements.tableViewNode.dataSource = self
        uiElements.tableViewNode.delegate = self
    }

    private func bindUIElements() {
        viewModel.output.viewControllerBackgroundColor
            .subscribe { [weak node] event in
                node?.backgroundColor = event.element
            }
            .disposed(by: bag)

        viewModel.output.title
            .subscribe { [weak self] event in
                self?.title = event.element
            }
            .disposed(by: bag)
    }
}

// MARK: - extension + ASTableDataSource -
extension SettingsViewController: ASTableDataSource {

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        viewModel.output.cellModels.count
    }

    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let model = viewModel.output.cellModels[indexPath.row]
        if indexPath.row == viewModel.output.cellModels.count - 1 {
            let cell = SettingsCellNode(model: model, showSeparator: false)
            return { cell }
        }
        let cell = SettingsCellNode(model: model)
        return { cell }
    }

}

// MARK: - extension + ASTableDelegate -
extension SettingsViewController: ASTableDelegate {

    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        let size = CGSize(width: UIScreen.main.bounds.width,
                          height: LocalConstants.cellHeight)
        return ASSizeRange(min: size, max: size)
    }

    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        uiElements.tableViewNode.deselectRow(at: indexPath, animated: true)
        viewModel.output.cellModels[indexPath.row].action()
    }
}
