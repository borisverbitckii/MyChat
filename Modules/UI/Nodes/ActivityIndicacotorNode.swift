//
//  ActivityIndicatorNode.swift
//  UI
//
//  Created by Boris Verbitsky on 13.04.2022.
//

import AsyncDisplayKit
import Lottie
import UIKit

final class ActivityIndicatorNode: ASDisplayNode {

    private lazy var activityIndicator: AnimationView = {
        $0.animation = Animation.named("activityAnimation")
        return $0
    }(AnimationView())

    // MARK: Init
    init(backgroundColor: UIColor) {
        super.init()
        self.backgroundColor = backgroundColor
    }

    // MARK: Public Methods
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASLayoutSpec()
    }
}



