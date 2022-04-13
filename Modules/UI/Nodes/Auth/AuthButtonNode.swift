//
//  AuthButton.swift
//  UI
//
//  Created by Boris Verbitsky on 13.04.2022.
//

import AsyncDisplayKit

public final class AuthButtonNode: ASButtonNode {

    // MARK: Private property
    private let image: ASImageNode

    // MARK: Init
    init(image: ASImageNode) {
        self.image = image
        super.init()
    }

    // MARK: Public Methods
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        image.style.preferredSize = CGSize(width: 25, height: 25)
        return ASCenterLayoutSpec(centeringOptions: .XY,
                                  sizingOptions: [],
                                  child: image)
    }
}
