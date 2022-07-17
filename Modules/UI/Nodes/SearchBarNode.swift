//
//  SearchBarNode.swift
//  UI
//
//  Created by Boris Verbitsky on 20.05.2022.
//

import AsyncDisplayKit

public final class SearchBarNode: ASDisplayNode {

    // MARK: Public properties
    public var textField: UITextField {
        searchBarView.searchTextField
    }

    public var backgroundImage: UIImage {
        get {
            searchBarView.backgroundImage ?? UIImage()
        }
        set {
            searchBarView.backgroundImage = newValue
        }
    }

    public var isTranslucent: Bool {
        get {
            searchBarView.isTranslucent
        }
        set {
            searchBarView.isTranslucent = newValue
        }
    }

    public var barTintColor: UIColor? {
        get {
            searchBarView.barTintColor
        }
        set {
            searchBarView.barTintColor = newValue
        }
    }

    public var font: UIFont? {
        get {
            searchBarView.searchTextField.font
        }
        set {
            searchBarView.searchTextField.font = newValue
        }
    }

    public var attributedPlaceholder: NSAttributedString? {
        get {
            searchBarView.searchTextField.attributedPlaceholder
        }
        set {
            searchBarView.searchTextField.attributedPlaceholder = newValue
        }
    }

    override public var style: ASLayoutElementStyle {
        let style = super.style
        style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: 67)
        return style
    }

    // MARK: Private properties
    private let searchBarView: UISearchBar
    private let searchBarNode: ASDisplayNode

    // MARK: Init
    public override init() {
        self.searchBarView = UISearchBar()
        self.searchBarView.barTintColor = .red
        searchBarNode = ASDisplayNode { [searchBarView] in
            searchBarView
        }
        super.init()
        automaticallyManagesSubnodes = true
    }

    // MARK: Public Methods
    public func setDelegate(with delegate: UISearchBarDelegate) {
        searchBarView.delegate = delegate
    }

    public func addTarget(target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        searchBarView.searchTextField.addTarget(target, action: action, for: controlEvents)
    }

    // MARK: Override methods
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASWrapperLayoutSpec(layoutElement: searchBarNode)
    }
}
