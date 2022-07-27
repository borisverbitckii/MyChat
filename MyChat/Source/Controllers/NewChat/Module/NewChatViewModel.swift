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
    func setupCellDelegate(with delegate: ContactUserCellNodeDelegate)
    func setupUserIcon(at index: Int)
    func fetchUsers(with name: String)
    func presentChatViewController(userAt index: Int)
}

protocol NewChatViewModelOutputProtocol {
    // UI
    var viewControllerBackgroundColor: BehaviorRelay<UIColor> { get }
    var navBarTitle: BehaviorRelay<String> { get }
    var searchBarPlaceholder: BehaviorRelay<String> { get }
    var searchFont: UIFont { get }
    var reloadCollectionNode: PublishRelay<Any?> { get }
    var searchBarTintColor: BehaviorRelay<UIColor> { get }
    var emptyStateTitleText: String { get }
    var emptyStateTitleFont: UIFont { get }
    var emptyStateTitleColor: UIColor { get }
    var navBarTitleFont: UIFont { get }
    var cancelButtonFont: UIFont { get }

    func getUsersCount() -> Int
    func getModel(at index: Int) -> ContactCellModel
}

final class NewChatViewModel {

    // MARK: Public properties
    var input: NewChatViewModelInputProtocol { return self }
    var output: NewChatViewModelOutputProtocol { return self }

    // UI
    let viewControllerBackgroundColor: BehaviorRelay<UIColor>
    let navBarTitle: BehaviorRelay<String>
    let searchBarPlaceholder: BehaviorRelay<String>
    let searchFont: UIFont
    let searchBarTintColor: BehaviorRelay<UIColor>
    let emptyStateTitleText: String
    let emptyStateTitleFont: UIFont
    let emptyStateTitleColor: UIColor
    let navBarTitleFont: UIFont
    let cancelButtonFont: UIFont

    lazy var reloadCollectionNode = PublishRelay<Any?>()

    // MARK: - Private properties
    private lazy var users = [ChatUser]() {
        didSet {
            reloadCollectionNode.accept(nil)
        }
    }

    private let coordinator: CoordinatorProtocol
    private let remoteDataBase: RemoteDataBaseManagerProtocol
    private let imageCacheManager: ImageCacheManagerProtocol
    private let presentingViewController: TransitionHandler

    private let palette: (NewChatViewControllerPalette) -> UIColor

    private lazy var bag = DisposeBag()

    private var cellDelegate: ContactUserCellNodeDelegate?

    // MARK: - Init
    init(coordinator: CoordinatorProtocol,
         remoteDataBase: RemoteDataBaseManagerProtocol,
         imageCacheManager: ImageCacheManagerProtocol,
         presentingViewController: TransitionHandler,
         texts: @escaping (NewChatViewControllerTexts) -> String,
         palette: @escaping (NewChatViewControllerPalette) -> UIColor,
         fonts: @escaping (NewChatViewControllerFonts) -> UIFont) {
        self.coordinator = coordinator
        self.remoteDataBase = remoteDataBase
        self.imageCacheManager = imageCacheManager
        self.presentingViewController = presentingViewController

        self.palette = palette

        /// Текст
        navBarTitle = BehaviorRelay<String>(value: texts(.navBarTitle))
        searchBarPlaceholder = BehaviorRelay<String>(value: texts(.searchBarPlaceholder))
        emptyStateTitleText = texts(.emptyStateText)
        /// Цвета
        viewControllerBackgroundColor = BehaviorRelay<UIColor>(value: palette(.newChatViewControllerBackgroundColor))
        searchBarTintColor = BehaviorRelay<UIColor>(value: palette(.searchBarTintColor))
        emptyStateTitleColor = palette(.emptyStateTextColor)
        /// Шрифты
        emptyStateTitleFont = fonts(.emptyStateText)
        navBarTitleFont = fonts(.navBarTitle)
        searchFont = fonts(.searchTextfieldPlaceholder)
        cancelButtonFont = fonts(.cancelButton)

        /// Подписка на изменения темы пользователя для автоматического обновления цвета
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(shouldUpdateColors),
                                               name: NSNotification.shouldUpdatePalette,
                                               object: nil)
    }

    @objc private func shouldUpdateColors() {
        searchBarTintColor.accept(palette(.searchBarTintColor))
        reloadCollectionNode.accept(nil)
    }
}

// MARK: - extension + NewChatViewModelProtocol
extension NewChatViewModel: NewChatViewModelProtocol {
}

// MARK: - extension + NewChatViewModelInputProtocol
extension NewChatViewModel: NewChatViewModelInputProtocol {

    func setupCellDelegate(with delegate: ContactUserCellNodeDelegate) {
        cellDelegate = delegate
    }

    func setupUserIcon(at index: Int) {
        let user = users[index]
        guard let avatarURL = user.avatarURL else {
            cellDelegate?.setupUserImage(with: nil)
            return
        }
        imageCacheManager.fetchImage(urlString: avatarURL)
            .subscribe { [weak self] image in
                guard let image = image else {
                    self?.cellDelegate?.setupUserImage(with: nil)
                    return
                }
                self?.cellDelegate?.setupUserImage(with: image)
            } onFailure: { [weak self] _ in
                self?.cellDelegate?.setupUserImage(with: nil)
            }
            .disposed(by: bag)
    }

    func fetchUsers(with searchText: String) {
        remoteDataBase.fetchUsersUUIDs(email: searchText)
            .subscribe { [weak self] result in
                switch result {
                case .success(let users):
                    if self?.users != users {
                        self?.users = users
                    }
                case .failure: break
                }
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

    func getModel(at index: Int) -> ContactCellModel {
        let user = users[index]
        return ContactCellModel(name: user.name,
                                nameColor: palette(.userNameCellColor),
                                email: user.email)
    }
}
