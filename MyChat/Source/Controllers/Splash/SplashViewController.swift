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

    // MARK: - Init
    init(viewModel: SplashViewModelProtocol) {
        self.viewModel = viewModel
        super.init(node: ASDisplayNode())
        view.backgroundColor = .white
        viewModel.input.viewDidLoad(presenter: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
