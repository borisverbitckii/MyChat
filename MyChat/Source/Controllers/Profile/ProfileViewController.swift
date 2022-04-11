//
//  ProfileViewController.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit

final class ProfileViewController: UIViewController {

    // MARK: - Private properties
    private let viewModel: ProfileViewModelProtocol

    // UIElements
    private let avatar: UIImageView = {
        return $0
    }(UIImageView())

    private let name: UILabel = {
        return $0
    }(UILabel())

    // MARK: - Init
    init(profileViewModel: ProfileViewModelProtocol) {
        self.viewModel = profileViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                            target: self,
                                                            action: #selector(logOutButtonPressed))
    }

    // MARK: - Private methods
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Profile" // TODO: - Исправить с ремоут текста -
    }

    // MARK: OBJC methods
    @objc private func logOutButtonPressed() {
        viewModel.input.signOut()
    }
}
