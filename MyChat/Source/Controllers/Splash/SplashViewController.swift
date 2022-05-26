//
//  SplashViewController.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UI
import UIKit
import RxSwift
import AsyncDisplayKit

private enum LocalConstants {
    static let backgroundColor = UIColor(named: "splashViewControllerBackgroundColor")
}

final class SplashViewController: ASDKViewController<ASDisplayNode> {

    // MARK: Public properties
    let viewModel: SplashViewModelProtocol

    // MARK: - Private properties
    private let uiElements: SplashUI

    // MARK: - Init
    init(viewModel: SplashViewModelProtocol,
         splashUI: SplashUI) {
        self.viewModel = viewModel
        self.uiElements = splashUI
        let node = ASDisplayNode()
        super.init(node: node)
        node.automaticallyManagesSubnodes = true
        node.layoutSpecBlock = layout()
        view.backgroundColor = LocalConstants.backgroundColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        uiElements.activityIndicator.startAnimating()
    }

    // MARK: Private methods
    private func layout() -> ASLayoutSpecBlock {
        { [uiElements] _, _ in
            ASWrapperLayoutSpec(layoutElement: uiElements.activityIndicator)
        }
    }
}
