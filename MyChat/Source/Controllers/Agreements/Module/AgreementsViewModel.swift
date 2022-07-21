//
//  AgreementsViewModel.swift
//  MyChat
//
//  Created by Boris Verbitsky on 19.07.2022.
//

import WebKit
import Logger

enum AgreementsType: String {
    case policy, termsOfUse
}

protocol AgreementsViewModelProtocol {
    var input: AgreementsViewModelInputProtocol { get }
    var output: AgreementsViewModelOutputProtocol { get }
}

protocol AgreementsViewModelInputProtocol {
    func setHideActivityIndicatorClosure(handler: @escaping () -> Void)
    func openURL(webView: WKWebView)
}

protocol AgreementsViewModelOutputProtocol {}

final class AgreementsViewModel: NSObject {

    // MARK: Public properties
    var input: AgreementsViewModelInputProtocol { self }
    var output: AgreementsViewModelOutputProtocol { self }

    // MARK: Private properties
    private let type: AgreementsType
    private var hideActivityIndicator: (() -> Void)?

    // MARK: Init
    init(type: AgreementsType) {
        self.type = type
    }
}

// MARK: - extension + AgreementsViewModelProtocol -
extension AgreementsViewModel: AgreementsViewModelProtocol {

}

// MARK: - extension + AgreementsViewModelInputProtocol -
extension AgreementsViewModel: AgreementsViewModelInputProtocol {
    func openURL(webView: WKWebView) {
        var url: URL?
        switch type {
        case .policy:
            url = URL(string: "https://docs.google.com/document/d/1gqTElvTKdOmLj_fogRlfP0LasBof0Fa8R3blUytAxVw/edit?usp=sharing")
        case .termsOfUse:
            url = URL(string: "https://docs.google.com/document/d/1lIHK3021-eFmmNysfwIe6UjbroFlcK4oFhFkXAJnxHg/edit?usp=sharing")
        }
        guard let url = url else { return }
        let request = URLRequest(url: url)
        webView.load(request)
        webView.navigationDelegate = self
        Logger.log(to: .info, message: "Открытие веб-страницы иницииаровано, тип контента \(type.rawValue)")
    }

    func setHideActivityIndicatorClosure(handler: @escaping () -> Void) {
        hideActivityIndicator = handler
    }
}

// MARK: - extension + AgreementsViewModelOutputProtocol -
extension AgreementsViewModel: AgreementsViewModelOutputProtocol {

}

// MARK: - extension + WKNavigationDelegate -
extension AgreementsViewModel: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideActivityIndicator?()
    }
}
