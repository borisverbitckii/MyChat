//
//  NewChatViewController.swift
//  MyChat
//
//  Created by Борис on 14.02.2022.
//

import UIKit

final class NewChatViewController: UIViewController {
    
    //MARK: - Private properties
    private let newChatViewModel: NewChatViewModelProtocol
    
    //MARK: - Init
    init(newChatViewModel: NewChatViewModelProtocol) {
        self.newChatViewModel = newChatViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
