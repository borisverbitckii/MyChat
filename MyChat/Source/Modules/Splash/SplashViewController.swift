//
//  SplashViewController.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit

final class SplashViewController: UIViewController {

    // MARK: - Private properties
    private let splashViewModel: SplashViewModelProtocol

    // MARK: - Init
    init(splashViewModel: SplashViewModelProtocol) {
        self.splashViewModel = splashViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red // remove this
        DispatchQueue.main.async { // fix this logic
            self.modalTransitionStyle = .crossDissolve
            self.dismiss(animated: true)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
