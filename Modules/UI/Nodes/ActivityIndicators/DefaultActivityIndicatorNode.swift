//
//  ActivityIndicatorNode.swift
//  UI
//
//  Created by Boris Verbitsky on 29.06.2022.
//

import UIKit
import AsyncDisplayKit

public final class DefaultActivityIndicatorNode: ASDisplayNode {

    // MARK: Public properties
    var activityIndicatorStyle: UIActivityIndicatorView.Style {
        get {
            activityIndicator.style
        }
        set {
            activityIndicator.style = newValue
        }
    }

    // MARK: Private properties
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.hidesWhenStopped = true
        return indicatorView
    }()

    private lazy var activityIndicatorNode = ASDisplayNode { [activityIndicator] in
        return activityIndicator
    }

    // MARK: Init
    public override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }

    // MARK: Override methods
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        ASWrapperLayoutSpec(layoutElement: activityIndicatorNode)
    }

    // MARK: Public Methods
    func startAnimating() {
        activityIndicator.startAnimating()
    }

    func stopAnimation() {
        activityIndicator.stopAnimating()
    }
}
