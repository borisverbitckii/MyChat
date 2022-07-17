//
//  TableViewWithEmptyState.swift
//  UI
//
//  Created by Boris Verbitsky on 04.07.2022.
//

import AsyncDisplayKit

/// Состояния таблицы, когда она пустая
public enum TableNodeEmptyStateType {
    case noChats              /// Нет чатов
    case noChatsFound         /// Не найден чат
    case startUserSearching   /// Не начат поиск по пользователям
    case normal               /// Пустая таблица
}

public final class TableNodeWithEmptyState: ASTableNode {

    // MARK: Private properties
    private var state: TableNodeEmptyStateType? {
        didSet {
            switch state {
            case .startUserSearching:
                emptyImageNode.image = UIImage(named: "startUserSearching")
            case .noChats:
                emptyImageNode.image = UIImage(named: "firstChat")
            case .noChatsFound:
                emptyImageNode.image = UIImage(named: "noChatsFound")
            default: break
            }
            transitionLayout(withAnimation: true, shouldMeasureAsync: false)
        }
    }

    /// Изображение пустого состояния
    private lazy var emptyImageNode: ASImageNode = {
        let imageNode = ASImageNode()
        imageNode.style.preferredSize = CGSize(width: 250, height: 250)
        imageNode.contentMode = .scaleAspectFill
        return imageNode
    }()

    /// Текст пустого состояния
    private lazy var emptyTextNode: ASTextNode = {
        let textNode = ASTextNode()
        return textNode
    }()

    /// Текст + изображения пустого состояния
    private lazy var emptyNode: ASDisplayNode = {
        let node = ASDisplayNode()
        node.automaticallyManagesSubnodes = true
        node.layoutSpecBlock = { [weak self] _, _ in
            guard let self = self else { return ASStackLayoutSpec() }
            let stack = ASStackLayoutSpec(direction: .vertical,
                                          spacing: 10,
                                          justifyContent: .start,
                                          alignItems: .center,
                                          children: [self.emptyImageNode,
                                                     self.emptyTextNode])
            let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 32,
                                                                   left: 0,
                                                                   bottom: 0,
                                                                   right: 0),
                                              child: stack)
            return insetSpec
        }
        return node
    }()

    // MARK: Init
    public override init(style: UITableView.Style) {
        super.init(style: style)
        automaticallyManagesSubnodes = true
    }

    // MARK: Override methods
    public override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        switch state {
        case .noChats, .noChatsFound, .startUserSearching:
            emptyNode.isHidden = false
            return ASWrapperLayoutSpec(layoutElement: emptyNode)
        default:
            emptyNode.isHidden = true
            return ASLayoutSpec()
        }
    }

    // MARK: Public Methods
    public func setupText(with text: String, font: UIFont, fontColor: UIColor) {
        let attributes = [NSAttributedString.Key.font: font,
                          NSAttributedString.Key.foregroundColor: fontColor]
        emptyTextNode.attributedText = NSAttributedString(string: text,
                                                          attributes: attributes)
    }

    public func setupState(with state: TableNodeEmptyStateType) {
        self.state = state
    }
}
