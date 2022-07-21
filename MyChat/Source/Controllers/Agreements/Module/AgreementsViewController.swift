//
//  AgreementsViewController.swift
//  MyChat
//
//  Created by Boris Verbitsky on 19.07.2022.
//

import UIKit

final class AgreementsViewController: UIViewController {

    // MARK: Private properties
    private let viewModel: AgreementsViewModel
    private let uiElements: AgreementsUI

    // MARK: Init
    init(viewModel: AgreementsViewModel,
         uiElements: AgreementsUI) {
        self.viewModel = viewModel
        self.uiElements = uiElements
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Override methods
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.input.setHideActivityIndicatorClosure { [uiElements] in
            uiElements.activityIndicator.stopAnimating()
        }

        addSubviews()
        layout()
        viewModel.openURL(webView: uiElements.webView)
    }

    // MARK: Private methods
    private func addSubviews() {
        view.addSubview(uiElements.webView)
        view.addSubview(uiElements.activityIndicator)
    }

    private func layout() {
        NSLayoutConstraint.activate([
            /// WebView
            uiElements.webView.leftAnchor.constraint(equalTo: view.leftAnchor),
            uiElements.webView.rightAnchor.constraint(equalTo: view.rightAnchor),
            uiElements.webView.topAnchor.constraint(equalTo: view.topAnchor),
            uiElements.webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        uiElements.activityIndicator.center = view.center
    }
}
