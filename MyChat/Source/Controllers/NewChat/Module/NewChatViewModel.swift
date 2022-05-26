//
//  NewChatViewModel.swift
//  MyChat
//
//  Created by Борис on 14.02.2022.
//

import UI
import Models
import RxSwift
import RxRelay
import Services

protocol NewChatViewModelProtocol {
    var input: NewChatViewModelInputProtocol { get }
    var output: NewChatViewModelOutputProtocol { get }
}

protocol NewChatViewModelInputProtocol {
    func fetchUsers(with name: String)
    func presentChatViewController(userAt index: Int)
}

protocol NewChatViewModelOutputProtocol {
    var navBarTitle: BehaviorRelay<String> { get }
    var searchBarPlaceholder: BehaviorRelay<String> { get }
    var reloadCollectionNode: PublishRelay<Any?> { get }
    var searchBarTintColor: BehaviorRelay<UIColor> { get }
    var cellModel: ContactUserCellModel { get }
    func getUsersCount() -> Int
    func getUser(at index: Int) -> ChatUser
}

final class NewChatViewModel {

    // MARK: Public properties
    var input: NewChatViewModelInputProtocol { return self }
    var output: NewChatViewModelOutputProtocol { return self }

    // UI
    var navBarTitle: BehaviorRelay<String>
    var searchBarPlaceholder: BehaviorRelay<String>
    var searchBarTintColor: BehaviorRelay<UIColor>
    var cellModel: ContactUserCellModel

    lazy var reloadCollectionNode = PublishRelay<Any?>()

    // MARK: - Private properties
    private lazy var users = [ChatUser]() {
        didSet {
            reloadCollectionNode.accept(nil)
        }
    }

    private let coordinator: CoordinatorProtocol
    private let remoteDataBase: RemoteDataBaseManagerProtocol
    private let presentingViewController: TransitionHandler

    private let texts: (NewChatViewControllerTexts) -> String
    private let palette: (NewChatViewControllerPalette) -> UIColor

    private lazy var bag = DisposeBag()

    // MARK: - Init
    init(coordinator: CoordinatorProtocol,
         remoteDataBase: RemoteDataBaseManagerProtocol,
         presentingViewController: TransitionHandler,
         texts: @escaping (NewChatViewControllerTexts) -> String,
         palette: @escaping (NewChatViewControllerPalette) -> UIColor) {
        self.coordinator = coordinator
        self.remoteDataBase = remoteDataBase
        self.presentingViewController = presentingViewController

        self.texts = texts
        self.palette = palette

        navBarTitle = BehaviorRelay<String>(value: texts(.navBarTitle))
        searchBarPlaceholder = BehaviorRelay<String>(value: texts(.searchBarPlaceholder))

        searchBarTintColor = BehaviorRelay<UIColor>(value: palette(.searchBarTintColor))
        self.cellModel = ContactUserCellModel(userNameColor: palette(.userNameCellColor))
    }
}

// MARK: - extension + NewChatViewModelProtocol
extension NewChatViewModel: NewChatViewModelProtocol {}

// MARK: - extension + NewChatViewModelInputProtocol
extension NewChatViewModel: NewChatViewModelInputProtocol {
    func fetchUsers(with searchText: String) {
        remoteDataBase.fetchUsersUUIDs(email: searchText)
            .subscribe { [weak self] users in
                if self?.users != users {
                    self?.users = users
                }
            } onFailure: { error in
                // TODO: Показать алерт контролллер
            }
            .disposed(by: bag)
    }

    func presentChatViewController(userAt index: Int) {
        let receiverUser = users[index]
        coordinator.pushChatViewController(receiverUser: receiverUser, presenterVC: presentingViewController)
    }
}

// MARK: - extension + NewChatViewModelOutputProtocol
extension NewChatViewModel: NewChatViewModelOutputProtocol {
    func getUsersCount() -> Int {
        users.count
    }

    func getUser(at index: Int) -> ChatUser {
        users[index]
    }

}
