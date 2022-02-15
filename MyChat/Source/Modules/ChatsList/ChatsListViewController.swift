//
//  ViewController.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit

final class ChatsListViewController: UIViewController {
    
    //MARK: - Private properties
    private let chatsListViewModel: ChatsListViewModelProtocol
    
    //UIElements
    private let chatsCollectionView: UICollectionView = {
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()))
    
    //MARK: - Init
    init(chatsListViewModel: ChatsListViewModelProtocol) {
        self.chatsListViewModel = chatsListViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple // TODO: Remove this
        setupNavigationBar()
    }
    
    //MARK: - Private methods
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = Text.navigationTitle(.chatList).text
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addChat))
    }
    
    //MARK: - OBJC methods
    @objc private func addChat() {
        print("add chat")
    }
}

