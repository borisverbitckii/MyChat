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
        view.backgroundColor = .white
        subscribe()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private methods
    private func subscribe() {
        viewModel.output.authState
            .subscribe { [viewModel] chatUserEvent in
                if let chatUser = chatUserEvent.element {
                    viewModel.input.presentNextViewController(withChatUser: chatUser, presenter: self)
                } else {
                    viewModel.input.presentNextViewController(withChatUser: nil, presenter: self)
                }
            }
            .disposed(by: dispodeBag)

    }
}
