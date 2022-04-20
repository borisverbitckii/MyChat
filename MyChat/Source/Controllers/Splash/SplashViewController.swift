//
//  SplashViewController.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit
import RxSwift
import AsyncDisplayKit

final class SplashViewController: ASDKViewController<ASDisplayNode> {

    // MARK: - Private properties
    private let viewModel: SplashViewModelProtocol
    private let disposeBag = DisposeBag()

    // MARK: - Init
    init(viewModel: SplashViewModelProtocol) {
        self.viewModel = viewModel
        super.init(node: ASDisplayNode())
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
                guard let chatUser = chatUserEvent.element else { return }
                viewModel.input.presentNextViewController(withChatUser: chatUser, presenter: self)
            }
            .disposed(by: disposeBag)

    }
}
