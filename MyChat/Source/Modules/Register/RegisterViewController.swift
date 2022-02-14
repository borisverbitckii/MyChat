//
//  RegisterViewController.swift
//  MyChat
//
//  Created by Борис on 14.02.2022.
//

import UIKit
import RxSwift

final class RegisterViewController: UIViewController {
    
    //MARK: - Private properties
    private let registerViewModel: RegisterViewModelProtocol
    private let bag = DisposeBag()
    
    //UIElements
    private let titleLabel: UILabel = {
        return $0
    }(UILabel())
    
    private let nameLabel: UILabel = {
        return $0
    }(UILabel())
    
    private let nameTextField: UITextField = {
        return $0
    }(UITextField())
    
    private let passwordLabel: UILabel = {
        return $0
    }(UILabel())
    
    private let passwordTestField: UITextField = {
        return $0
    }(UITextField())
    
    private let submitButton: UIButton = {
        $0.addTarget(self, action: #selector(submitButtonWasTapped), for: .touchUpInside)
        $0.setTitle(Text.button(.register).text, for: .normal)
        $0.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        $0.backgroundColor = .red
        return $0
    }(UIButton(type: .custom))
    
    //MARK: - Init
    init(registerViewModel: RegisterViewModelProtocol) {
        self.registerViewModel = registerViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        view.backgroundColor = .green
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: - Private methods
    private func subscribe() {
        registerViewModel.state.subscribe { state in
            
            //TODO: Cделать различное отображение при разных состояниях
            switch state.element {
            case .auth:
                break
            case .register:
                break
            case .none: break
            }
        }.disposed(by: bag)
    }
    
    private func addSubviews() {
        view.addSubview(submitButton)
    }
    
    //MARK: - OBJC methods
    @objc private func submitButtonWasTapped() {
        registerViewModel.presentTabBarController()
    }
}
