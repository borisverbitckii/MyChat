//
//  ProfileViewController.swift
//  MyChat
//
//  Created by Boris Verbitsky on 10.06.2022.
//

import UI
import RxSwift
import AsyncDisplayKit

final class ProfileViewController: ASDKViewController<ASTableNode> {

    // MARK: Public properties
    let viewModel: ProfileViewModelProtocol
    let uiElements: ProfileUI

    // MARK: Private properties
    private lazy var bag = DisposeBag()

    // MARK: Init
    init(viewModel: ProfileViewModelProtocol,
         uiElements: ProfileUI) {
        self.viewModel = viewModel
        self.uiElements = uiElements
        let node = uiElements.tableNode
        super.init(node: node)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        uiElements.tableNode.contentInset = viewModel.output.tableViewContentInset
        setupDelegates()
        bindUIElements()
    }

    // MARK: Private methods
    private func setupDelegates() {
        uiElements.tableNode.dataSource = self
    }

    private func bindUIElements() {
        viewModel.output.viewControllerBackgroundColor
            .subscribe { [weak self] event in
                self?.node.backgroundColor = event.element
            }
            .disposed(by: bag)

        viewModel.output.reloadCellWithUserImage
            .subscribe { [uiElements] _ in
                let indexPath = IndexPath(row: 0, section: 0)
                uiElements.tableNode.reloadRows(at: [indexPath], with: .automatic)
            }
            .disposed(by: bag)

        viewModel.output.popViewController
            .subscribe { [weak self] _ in
                self?.popViewController()
            }
            .disposed(by: bag)
    }
}

// MARK: - extension + ASTableDataSource -
extension ProfileViewController: ASTableDataSource {

    func numberOfSections(in tableNode: ASTableNode) -> Int {
        3
    }

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {

        if indexPath.section == 0 {
            let imagePickerClosure: () -> Void = { [weak self] in
                guard let presenter = self else { return }
                self?.viewModel.output.imagePickerClosure(presenter)
            }
            let cell = ImageCellNode(imagePickerClosure: imagePickerClosure,
                                     image: viewModel.output.userImage)
            viewModel.input.setImageActivityIndicatorDelegate(with: cell)
            cell.configure(buttonTitle: viewModel.output.uploadButtonText,
                           buttonFont: viewModel.output.uploadButtonFont)
            return { cell }
        }

        if indexPath.section == 1 {
            let cell = TextFieldCellNode(model: viewModel.output.cellModel,
                                         userInfoClosure: viewModel.output.userInfoClosure)
            cell.textField.delegate = self
            cell.configure(userName: viewModel.output.userName,
                           placeholder: viewModel.output.nameTextfieldPlaceholder,
                           font: viewModel.output.textfieldFont)
            return { cell }
        }

        if indexPath.section == 2 {
            let cell = ButtonCellNode(saveButtonClosure: viewModel.output.saveButtonClosure)
            cell.configure(buttonTitle: viewModel.output.saveButtonTitle,
                           font: viewModel.output.saveButtonFont)
            return { cell }
        }

        return { ASCellNode() }
    }
}

// MARK: - extension + UITextFieldDelegate -
extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
