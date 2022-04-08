//
//  TextFieldWithBottomBorderNode.swift
//  MyChat
//
//  Created by Boris Verbitsky on 06.04.2022.
//

import AsyncDisplayKit

private enum LocalConstants {
    static let borderHeight: CGFloat = 3
    static let colorForBackground = UIColor.gray.withAlphaComponent(0.20)
}

final class TextFieldWithBottomBorderNode: ASDisplayNode {

    // MARK: Public properties
    let textfield = ASTextFieldNode()

    // MARK: Private Properties
    private let line: ASDisplayNode = {
        $0.style.preferredSize.height = LocalConstants.borderHeight
        $0.backgroundColor = LocalConstants.colorForBackground
        return $0
    }(ASDisplayNode())

    // MARK: Ovveride methods
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let insets = UIEdgeInsets(top: .infinity, left: 0, bottom: 0, right: 0)
        let insetsSpec = ASInsetLayoutSpec(insets: insets, child: line)
        return ASOverlayLayoutSpec(child: textfield, overlay: insetsSpec)
    }
}
