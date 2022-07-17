//
//  NavBarNode.swift
//  UI
//
//  Created by Boris Verbitsky on 20.05.2022.
//

import AsyncDisplayKit

final public class NavBarNode: ASDisplayNode {

    // MARK: Public properties
    public var shadowImage: UIImage {
        get {
            navBarView.shadowImage ?? UIImage()
        }
        set {
            navBarView.shadowImage = newValue
        }
    }

    override public var style: ASLayoutElementStyle {
        let style = super.style
        style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 54)
        return style
    }

    public var titleTextAttributes: [NSAttributedString.Key: Any]? {
        get {
            navBarView.titleTextAttributes
        }
        set {
            navBarView.titleTextAttributes = newValue
        }
    }

    // MARK: Private properties
    private let navBarView: UINavigationBar
    private let navBarNode: ASDisplayNode

    // MARK: Init
    public override init() {
        self.navBarView = UINavigationBar()
        navBarNode = ASDisplayNode { [navBarView] in
            navBarView
        }
        super.init()
        automaticallyManagesSubnodes = true
    }

    // MARK: Override methods
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASWrapperLayoutSpec(layoutElement: navBarNode)
    }

    // MARK: Public Methods
    public func setItems(with items: [UINavigationItem], animated: Bool) {
        navBarView.setItems(items, animated: animated)
    }
}
