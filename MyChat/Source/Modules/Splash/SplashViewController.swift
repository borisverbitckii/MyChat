//
//  SplashViewController.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit
import RxSwift

final class SplashViewController: UIViewController {

    // MARK: - Private properties
    private let viewModel: SplashViewModelProtocol
    private let dispodeBag = DisposeBag()

    // MARK: - Init
    init(viewModel: SplashViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        subscribe()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private methods
    private func subscribe() {
        viewModel.output.authState
            .subscribe { [weak self] userEvent in
                guard let self = self else { return }
                if let user = userEvent.element {
                    self.viewModel.input.presentNextViewController(withUser: user, presenter: self)
                } else {
                    self.viewModel.input.presentNextViewController(withUser: nil, presenter: self)
                }
            }
            .disposed(by: dispodeBag)

    }
}
