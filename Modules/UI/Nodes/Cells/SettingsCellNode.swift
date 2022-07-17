//
//  SettingsCell.swift
//  UI
//
//  Created by Boris Verbitsky on 30.06.2022.
//

import Models
import AsyncDisplayKit

private enum LocalConstants {
    static let titleInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
}

public final class SettingsCellNode: ASCellNode {

    // MARK: Private properties
    private lazy var titleNode = ASTextNode()
    private lazy var separatorNode: ASDisplayNode = {
        let line = ASDisplayNode()
        line.backgroundColor = .gray
        line.alpha = 0.25
        return line
    }()

    private let showSeparator: Bool

    // MARK: Init
    public init(model: SettingsCellModel, showSeparator: Bool = true) {
        self.showSeparator = showSeparator
        super.init()
        automaticallyManagesSubnodes = true
        let attributes: [NSAttributedString.Key : Any] = [.font: model.font, .foregroundColor : model.fontColor]
        titleNode.attributedText = NSAttributedString(string: model.title, attributes: attributes)
        backgroundColor = model.backgroundColor
    }

    // MARK: Override methods
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let insets = LocalConstants.titleInsets
        let insetsSpec =  ASInsetLayoutSpec(insets: insets,
                                            child: titleNode)
        let centerSpec = ASCenterLayoutSpec(horizontalPosition: .none,
                                            verticalPosition: .center,
                                            sizingOption: [],
                                            child: insetsSpec)

        if showSeparator {
            separatorNode.style.preferredSize = CGSize(width: constrainedSize.max.width - 32,
                                                       height: 0.5)
            separatorNode.style.alignSelf = .center
            let vStack = ASStackLayoutSpec()
            vStack.direction = .vertical
            vStack.spacing = 11
            vStack.children = [centerSpec, separatorNode]
            vStack.justifyContent = .end
            return vStack
        }

        return centerSpec
    }
}
