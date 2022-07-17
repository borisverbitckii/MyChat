//
//  buttonCellNode.swift
//  UI
//
//  Created by Boris Verbitsky on 12.06.2022.
//

import AsyncDisplayKit

private enum LocalConstants {
    static let buttonSize = CGSize(width: 250, height: 40)
    static let cellInsets = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 16)
}

public final class ButtonCellNode: ASCellNode {

    // MARK: Public properties
    public lazy var button: ASButtonNode = {
        let button = ASButtonNode()
        button.style.preferredSize = LocalConstants.buttonSize
        button.addTarget(self, action: #selector(buttonTapped), forControlEvents: .touchUpInside)
        return button
    }()

    // MARK: Private properties
    private let saveButtonClosure: () -> Void

    // MARK: Init
    public init(saveButtonClosure: @escaping () -> Void) {
        self.saveButtonClosure = saveButtonClosure
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = .clear
    }

    // MARK: Override methods
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let centerSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: button)
        let insetsSpec = ASInsetLayoutSpec(insets: LocalConstants.cellInsets, child: centerSpec)
        return insetsSpec
    }

    // MARK: Public Methods
    public func configure(buttonTitle: String, font: UIFont) {
        button.setTitle(buttonTitle, with: font, with: nil, for: .normal)
    }

    // MARK: Objc private methods
    @objc private func buttonTapped() {
        button.isUserInteractionEnabled = false
        defer {
            button.isUserInteractionEnabled = true
        }
        saveButtonClosure()
    }
}
