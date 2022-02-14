//
//  TabBarController.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit

final class TabBarController: UITabBarController {
    
    //MARK: - Private properties
    private let tabBarViewModel: TabBarControllerViewModelProtocol
    private var splashIsShown = false
    
    //MARK: - Init
    init(tabBarViewModel: TabBarControllerViewModelProtocol) {
        self.tabBarViewModel = tabBarViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !splashIsShown {
            tabBarViewModel.presentSplashModule(transitionHandler: self)
            splashIsShown = true 
        }
    }
}
