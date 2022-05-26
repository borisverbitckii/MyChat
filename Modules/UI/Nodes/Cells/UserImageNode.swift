//
//  UserImageNode.swift
//  UI
//
//  Created by Boris Verbitsky on 21.05.2022.
//

import AsyncDisplayKit

public final class UserImageNode: ASNetworkImageNode {

    // MARK: Public Methods
    public override func placeholderImage() -> UIImage? {
        UIImage(named: "userImagePlaceholder")?.withRenderingMode(.alwaysTemplate)
    }
}
