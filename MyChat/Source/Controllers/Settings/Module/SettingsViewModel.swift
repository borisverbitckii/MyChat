//
//  SettingsViewModel.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Models
import RxSwift
import RxRelay
import Services

protocol SettingsViewModelProtocol {
    var input: SettingsViewModelInputProtocol { get }
    var output: SettingsViewModelOutputProtocol { get }
}

protocol SettingsViewModelInputProtocol {
    func viewDidLoad(presenter: TransitionHandler)
}

protocol SettingsViewModelOutputProtocol {
    var viewControllerBackgroundColor: BehaviorRelay<UIColor> { get }
    var title: BehaviorRelay<String> { get }
    var cellModels: [SettingsCellModel] { get }
}

final class SettingsViewModel {

    // MARK: - Public properties
    var input: SettingsViewModelInputProtocol { return self }
    var output: SettingsViewModelOutputProtocol { return self }

    // UI
    let viewControllerBackgroundColor: BehaviorRelay<UIColor>
    let title: BehaviorRelay<String>
    private(set) lazy var cellModels = [SettingsCellModel]()

    // MARK: - Private properties
    private let user: ChatUser

    private let coordinator: CoordinatorProtocol
    private let authManager: AuthManagerSettingsProtocol
    private let storageManager: StorageManagerProtocol
    private let remoteDataBaseManager: RemoteDataBaseManagerProtocol
    private let webSocketFacade: WebSocketsFlowFacadeProtocol
    private let disposeBag = DisposeBag()

    private let texts: (SettingsViewControllerTexts) -> String
    private let fonts: (SettingsViewControllerFonts) -> UIFont
    private let palette: (SettingsViewControllerPalette) -> UIColor

    // MARK: - Init
    init(chatUser: ChatUser,
         coordinator: CoordinatorProtocol,
         authManager: AuthManagerSettingsProtocol,
         storageManager: StorageManagerProtocol,
         remoteDataBaseManager: RemoteDataBaseManagerProtocol,
         webSocketsFacade: WebSocketsFlowFacadeProtocol,
         texts: @escaping (SettingsViewControllerTexts) -> String,
         fonts: @escaping (SettingsViewControllerFonts) -> UIFont,
         palette: @escaping (SettingsViewControllerPalette) -> UIColor) {
        self.user = chatUser

        self.coordinator = coordinator
        self.authManager = authManager
        self.storageManager = storageManager
        self.webSocketFacade = webSocketsFacade
        self.remoteDataBaseManager = remoteDataBaseManager

        self.texts = texts
        self.fonts = fonts
        self.palette = palette

        /// Цвета
        let vcBackgroundColor = palette(.settingsViewControllerBackgroundColor)
        viewControllerBackgroundColor = BehaviorRelay<UIColor>(value: vcBackgroundColor)

        /// Заголовки
        title = BehaviorRelay<String>(value: texts(.title))

        /// Подписка на изменения темы пользователя для автоматического обновления цвета
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(shouldUpdateColors),
                                               name: NSNotification.shouldUpdatePalette,
                                               object: nil)
    }

    // MARK: Private methods
    private func generateCellModels(presenter: TransitionHandler) {
        /// Profile
        let profileModel = SettingsCellModel(title: texts(.profileCellTitle),
                                             font: fonts(.cellTitle),
                                             backgroundColor: palette(.settingsCellBackgroundColor),
                                             fontColor: palette(.settingsCellFontColor)) { [weak self] in
            guard let self = self else { return }
            self.remoteDataBaseManager.fetchUser(fetchType: .selfUser, id: self.user.id)
                .subscribe { result in
                    switch result {
                    case .success(let user):
                        if let user = user {
                            self.coordinator.pushProfileViewController(chatUser: user,
                                                                       presenter: presenter)
                        }
                    case .failure: break
                    }
                }
                .disposed(by: self.disposeBag)
        }
        cellModels.append(profileModel)

        /// Logout
        let logoutModel = SettingsCellModel(title: texts(.logOutCellTitle),
                                            font: fonts(.cellTitle),
                                            backgroundColor: palette(.settingsCellBackgroundColor),
                                            fontColor: palette(.settingsCellFontColor)) { [weak self] in
            self?.signOut()
        }
        cellModels.append(logoutModel)
    }

    private func signOut() {
        authManager.signOut()
            .subscribe { [weak self, disposeBag] _ in
                self?.storageManager.removeEverything()
                    .subscribe { _ in
                        self?.coordinator.presentRegisterViewController()
                        self?.webSocketFacade.closeConnection()
                    }
                    .disposed(by: disposeBag)

            }
            .disposed(by: disposeBag)
    }

    // MARK: Objc private methods
    @objc private func shouldUpdateColors() {
        viewControllerBackgroundColor.accept(palette(.settingsViewControllerBackgroundColor))
    }
}

// MARK: - extension + SettingsViewModelProtocol
extension SettingsViewModel: SettingsViewModelProtocol {}

// MARK: - extension + SettingsViewModelInputProtocol
extension SettingsViewModel: SettingsViewModelInputProtocol {

    func viewDidLoad(presenter: TransitionHandler) {
        generateCellModels(presenter: presenter)
    }
}

// MARK: - extension + SettingsViewModelOutputProtocol
extension SettingsViewModel: SettingsViewModelOutputProtocol {}
