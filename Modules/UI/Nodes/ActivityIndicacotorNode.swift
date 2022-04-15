//
//  ActivityIndicatorNode.swift
//  UI
//
//  Created by Boris Verbitsky on 13.04.2022.
//

import AsyncDisplayKit
import Lottie
import UIKit

protocol ActivityIndicatoProtocol {
    func startAnimating()
    func stopAnimating()
}

public final class ActivityIndicatorNode: ASDisplayNode {

    private lazy var activityIndicatorAnimationView: AnimationView = {
        assert(Animation.named("activityAnimation") != nil, "Не найден файл анимации")
        $0.animation = Animation.named("activityAnimation")
        $0.contentMode = .scaleAspectFill
        $0.play(fromProgress: 0, toProgress: 1, loopMode: .loop)
        return $0
    }(AnimationView())

    private lazy var activityIndicatorNode: ASDisplayNode = {
        let node = ASDisplayNode {
            return self.activityIndicatorAnimationView
        }
        return node
    }()

    // MARK: Override properties
    public override var style: ASLayoutElementStyle {
        let originalStyle = super.style
        originalStyle.preferredSize = CGSize(width: 100, height: 100)
        return originalStyle
    }

    public override init() {
        super.init()
        borderWidth = 4
        clipsToBounds = true
        automaticallyManagesSubnodes = true
        cornerRadius = style.preferredSize.height / 2
        borderColor = UIColor.gray.withAlphaComponent(0.15).cgColor
    }


    // MARK: Public Methods
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASWrapperLayoutSpec(layoutElement: activityIndicatorNode)
    }
}

extension ActivityIndicatorNode: ActivityIndicatoProtocol {

    public func startAnimating() {
        activityIndicatorAnimationView.play(fromProgress: 0, toProgress: 1, loopMode: .loop)
    }

    public func stopAnimating() {
        activityIndicatorAnimationView.pause()
    }
}



