//
//  EmptyViewController.swift
//  MyChat
//
//  Created by Boris Verbitsky on 19.04.2022.
//

final class EmptyViewController: ASDKViewController<ASDisplayNode> {
    // MARK: Init
    override init() {
        super.init(node: ASDisplayNode())
        node.backgroundColor = .white // TODO Прокинуть палетку
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
