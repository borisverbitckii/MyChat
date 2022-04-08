//
//  ProfileViewController.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit

final class ProfileViewController: UIViewController {

    // MARK: - Private properties
    private let profileViewModel: ProfileViewModelProtocol

    // UIElements
    private let avatar: UIImageView = {
        return $0
    }(UIImageView())

    private let name: UILabel = {
        return $0
    }(UILabel())

    // MARK: - Init
    init(profileViewModel: ProfileViewModelProtocol) {
        self.profileViewModel = profileViewModel
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
    }

    // MARK: - Private methods
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Profile" // TODO: - Исправить с ремоут текста -
    }
}
