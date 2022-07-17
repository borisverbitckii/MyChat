//
//  AuthButton.swift
//  UI
//
//  Created by Boris Verbitsky on 13.04.2022.
//

import AsyncDisplayKit

public final class AuthButtonNode: ASButtonNode {

    private let image: UIImage?

    // MARK: Init
    init(image: UIImage) {
        self.image = image
        super.init()
        cornerRadius = 8
        clipsToBounds = true
    }

    // MARK: Public Methods
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.imageNode.image = image
        imageNode.style.preferredSize = CGSize(width: 25, height: 25)
        return ASCenterLayoutSpec(centeringOptions: .XY,
                                  sizingOptions: [],
                                  child: imageNode)
    }
}
