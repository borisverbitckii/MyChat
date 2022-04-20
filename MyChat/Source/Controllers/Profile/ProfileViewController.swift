//
//  ProfileViewController.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import AsyncDisplayKit
import RxSwift

final class ProfileViewController: ASDKViewController<ASDisplayNode> {

    // MARK: Private properties
    private let viewModel: ProfileViewModelProtocol
    private let bag = DisposeBag()

    // UIElements
    private let avatar: UIImageView = {
        return $0
    }(UIImageView())

    private let name: UILabel = {
        return $0
    }(UILabel())

    // MARK: Init
    init(profileViewModel: ProfileViewModelProtocol) {
        self.viewModel = profileViewModel
        super.init(node: ASDisplayNode())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        bindUIElements()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                            target: self,
                                                            action: #selector(logOutButtonPressed))
    }

    // MARK: Private methods
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Profile" // TODO: - Исправить с ремоут текста -
    }

    func bindUIElements() {
        viewModel.output.viewControllerBackgroundColor
            .subscribe { [weak view] event in
                view?.backgroundColor = event.element
            }
            .disposed(by: bag)
    }

    // MARK: OBJC methods
    @objc private func logOutButtonPressed() {
        viewModel.input.signOut(presenter: self)
    }
}
