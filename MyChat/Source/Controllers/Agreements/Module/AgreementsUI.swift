//
//  uiElements.swift
//  MyChat
//
//  Created by Boris Verbitsky on 19.07.2022.
//

import WebKit

final class AgreementsUI {
    private(set) lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    private(set) lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.startAnimating()
        indicator.hidesWhenStopped = true
        indicator.style = .medium
        return indicator
    }()
}
