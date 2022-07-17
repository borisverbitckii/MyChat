//
//  ImageCell.swift
//  UI
//
//  Created by Boris Verbitsky on 12.06.2022.
//

import UIKit
import AsyncDisplayKit

private enum LocalConstants {
    /// ImageNode
    static let imageSize = CGSize(width: 100, height: 100)
    static let imageCornerRadius: CGFloat = 50
    static let placeholderImage = UIImage(named: "userImagePlaceholder")?.withRenderingMode(.alwaysTemplate)
    static let imageTintColor = UIColor.lightGray.withAlphaComponent(0.4)

    /// Button
    static let buttonSize = CGSize(width: 200, height: 40)
    static let buttonCornerRadius: CGFloat = 8

    static let spacing: CGFloat = 6
    static let insets = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
}

public protocol ImageActivityIndicatorDelegate: AnyObject {
    func showActivityIndicator()
    func hideActivityIndicator()
}

public final class ImageCellNode: ASCellNode {

    // MARK: Public properties
    private(set) lazy var imageNode: ASImageNode = {
        let imageNode = ASImageNode()
        imageNode.image = LocalConstants.placeholderImage
        imageNode.tintColor = LocalConstants.imageTintColor
        imageNode.style.preferredSize = LocalConstants.imageSize
        imageNode.cornerRadius = LocalConstants.imageCornerRadius
        imageNode.clipsToBounds = true
        imageNode.contentMode = .scaleAspectFill

        imageNode.addTarget(self, action: #selector(uploadPhoto), forControlEvents: .touchUpInside)
        return imageNode
    }()
    private(set) lazy var uploadButton: ASButtonNode = {
        let button = ASButtonNode()
        button.style.preferredSize = LocalConstants.buttonSize
        button.cornerRadius = LocalConstants.buttonCornerRadius
        button.clipsToBounds = true

        button.addTarget(self, action: #selector(uploadPhoto), forControlEvents: .touchUpInside)
        return button
    }()

    private lazy var activityIndicator: DefaultActivityIndicatorNode = {
        let indicator = DefaultActivityIndicatorNode()
        indicator.activityIndicatorStyle = .medium
        return indicator
    }()

    // MARK: Private properties
    private let imagePickerClosure: () -> Void
    private var isActivityIndicatorIsShown = false

    // MARK: Init
    public init(imagePickerClosure: @escaping () -> Void,
                image: UIImage? = nil) {
        self.imagePickerClosure = imagePickerClosure

        super.init()

        automaticallyManagesSubnodes = true
        backgroundColor = .clear

        if let image = image {
            imageNode.image = image
        }
    }

    // MARK: Override methods
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

        let vStack = ASStackLayoutSpec()
        vStack.direction = .vertical
        vStack.spacing = LocalConstants.spacing
        vStack.alignItems = .center

        if isActivityIndicatorIsShown {
            let overlaySpec = ASOverlayLayoutSpec(child: imageNode,
                                                  overlay: activityIndicator)
            vStack.children = [overlaySpec, uploadButton]
        } else {
            vStack.children = [imageNode, uploadButton]
        }
        let centerSpec = ASCenterLayoutSpec(centeringOptions: .X, sizingOptions: [], child: vStack)
        let insetsSpec = ASInsetLayoutSpec(insets: LocalConstants.insets,
                                           child: centerSpec)
        return insetsSpec
    }

    // MARK: Public Methods
    public func configure(buttonTitle: String, buttonFont: UIFont) {
        uploadButton.setTitle(buttonTitle,
                              with: buttonFont,
                              with: nil,
                              for: .normal)
    }

    // MARK: Private methods
    @objc private func uploadPhoto() {
        imagePickerClosure()
    }
}

// MARK: - extension + ImageActivityIndicatorDelegate -
extension ImageCellNode: ImageActivityIndicatorDelegate {
    public func showActivityIndicator() {
        activityIndicator.startAnimating()
        isActivityIndicatorIsShown = true
        transitionLayout(withAnimation: true, shouldMeasureAsync: false)
    }

    public func hideActivityIndicator() {
        activityIndicator.stopAnimation()
    }
}
