//
//  ProfileViewModel.swift
//  MyChat
//
//  Created by Boris Verbitsky on 10.06.2022.
//

import UI
import UIKit
import Logger
import Models
import Photos
import RxSwift
import RxRelay
import Services

enum PresenterSource {
    case byRegisterVC
    case bySettingsVC
}

protocol ProfileViewModelProtocol {
    var input: ProfileViewModelInputProtocol { get }
    var output: ProfileViewModelOutputProtocol { get }
}

protocol ProfileViewModelInputProtocol {
    func setImageActivityIndicatorDelegate(with delegate: ImageActivityIndicatorDelegate)
}

protocol ProfileViewModelOutputProtocol {
    /// UI
    var uploadButtonText: String { get }
    var uploadButtonFont: UIFont { get }
    var nameTextfieldPlaceholder: String { get }
    var textfieldFont: UIFont { get }
    var saveButtonTitle: String { get }
    var saveButtonFont: UIFont { get }
    var tableViewContentInset: UIEdgeInsets { get }
    var viewControllerBackgroundColor: BehaviorRelay<UIColor> { get }
    var cellModel: ProfileCellModel { get }

    var userImage: UIImage? { get }
    var userName: String { get }

    var reloadCellWithUserImage: PublishRelay<Any?> { get }

    var userInfoClosure: (String) -> Void { get }
    var imagePickerClosure: (TransitionHandler) -> Void { get }
    var saveButtonClosure: () -> Void { get }

    var popViewController: PublishRelay<Any?> { get }
}

final class ProfileViewModel: NSObject {

    // MARK: Public properties
    var input: ProfileViewModelInputProtocol { self }
    var output: ProfileViewModelOutputProtocol { self }

    /// Клоужер, чтобы выдернуть из ячейки имя пользователя
    private(set) lazy var userInfoClosure: (String) -> Void = { [weak self] value in
        self?.userName = value
    }

    /// Клоужер, чтобы презентовать alertController выбора, откуда взять фото (камера/библиотека)
    private(set) lazy var imagePickerClosure: (TransitionHandler) -> Void = { [weak self] presenter in
                guard let self = self else { return }
                let cameraAction = UIAlertAction(title: self.texts(.camera),
                                                 style: .default) { _ in
                    self.coordinator.presentImagePickerController(presenter: presenter,
                                                                  delegate: self,
                                                                  source: .camera)
                }
                let libraryAction = UIAlertAction(title: self.texts(.library),
                                                  style: .default) { _ in
                    self.checkImagePickerPermission { permission in
                        if permission {
                            self.coordinator.presentImagePickerController(presenter: presenter,
                                                                          delegate: self,
                                                                          source: .photoLibrary)
                        }
                    }
                }
                self.coordinator.presentAlertController(style: .actionSheet,
                                                        title: self.texts(.alertTitle),
                                                        message: "",
                                                        actions: [cameraAction, libraryAction],
                                                        presenter: presenter)
    }

    /// Клоужер для сохранения информации о профиле
    private(set) lazy var saveButtonClosure: () -> Void = { [weak self, bag] in
        guard let self = self,
              let userName = self.userName else { return }
        var imageToReplace = self.chatUser.avatarURL
        if self.userImageURLString != nil {
            imageToReplace = self.userImageURLString
        }
        
        self.remoteDataBaseManager.updateUser(id: self.chatUser.id,
                                              name: userName,
                                              userIconURLString: imageToReplace)
        .subscribe { _ in
            self.chatUser.name = userName
            self.chatUser.avatarURL = imageToReplace
            self.presentNextViewController()
        }
        .disposed(by: bag)
    }

    private(set) lazy var popViewController = PublishRelay<Any?> ()

    // UI
    let uploadButtonText: String
    let uploadButtonFont: UIFont
    let nameTextfieldPlaceholder: String
    let textfieldFont: UIFont
    let saveButtonTitle: String
    let saveButtonFont: UIFont
    let viewControllerBackgroundColor: BehaviorRelay<UIColor>
    let cellModel: ProfileCellModel
    var userImage: UIImage?
    var userName: String

    private(set) var tableViewContentInset: UIEdgeInsets
    private(set) lazy var reloadCellWithUserImage = PublishRelay<Any?>()

    // MARK: Private properties
    private let source: PresenterSource
    private var chatUser: ChatUser
    private let coordinator: CoordinatorProtocol
    private let remoteDataBaseManager: RemoteDataBaseManagerProtocol
    private let remoteFileStorageManager: RemoteFileStorageManagerProtocol
    private lazy var bag = DisposeBag()

    private let texts: (ProfileViewControllerTexts) -> String
    private let palette: (ProfileViewControllerPalette) -> UIColor

    private var userImageURLString: String?

    private var imageActivityIndicatorDelegate: ImageActivityIndicatorDelegate?

    // MARK: Init
    init(source: PresenterSource,
         chatUser: ChatUser,
         coordinator: CoordinatorProtocol,
         imageCacheManager: ImageCacheManagerProtocol,
         remoteFileStorageManager: RemoteFileStorageManagerProtocol,
         remoteDataBaseManager: RemoteDataBaseManagerProtocol,
         texts: @escaping (ProfileViewControllerTexts) -> String,
         palette: @escaping (ProfileViewControllerPalette) -> UIColor,
         fonts: @escaping (ProfileViewControllerFonts) -> UIFont) {

        self.source = source

        switch source {
        case .byRegisterVC:
            tableViewContentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        case .bySettingsVC:
            tableViewContentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        self.chatUser = chatUser
        self.coordinator = coordinator
        self.remoteFileStorageManager = remoteFileStorageManager
        self.remoteDataBaseManager = remoteDataBaseManager

        self.texts = texts
        self.palette = palette

        self.cellModel = ProfileCellModel(textfieldBackgroundColor: palette(.textfieldBackgroundColor))

        /// Цвет
        viewControllerBackgroundColor = BehaviorRelay<UIColor>(value: palette(.profileViewControllerBackgroundColor))

        /// Текст
        uploadButtonText = texts(.uploadButtonText)
        nameTextfieldPlaceholder = texts(.nameTextfieldPlaceholder)
        saveButtonTitle = texts(.saveButtonTitle)

        /// Шрифт
        uploadButtonFont = fonts(.button)
        saveButtonFont = fonts(.button)
        textfieldFont = fonts(.textfield)

        userName = chatUser.name

        super.init()

        imageCacheManager.fetchImage(urlString: chatUser.avatarURL ?? "")
            .subscribe { [weak self] image in
                self?.userImageURLString = chatUser.avatarURL
                self?.userImage = image
                self?.reloadCellWithUserImage.accept(nil)
            }
            .disposed(by: bag)

        /// Подписка на изменения темы пользователя для автоматического обновления цвета
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(shouldUpdateColors),
                                               name: NSNotification.shouldUpdatePalette,
                                               object: nil)
    }

    // MARK: Private methods
    private func checkImagePickerPermission(completion: @escaping (Bool) -> Void) {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus ==  PHAuthorizationStatus.authorized {
                    DispatchQueue.main.async {
                        completion(true)
                    }
                }
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        case .restricted, .denied, .limited:
            DispatchQueue.main.async {
                completion(false)
            }
        case .authorized:
            DispatchQueue.main.async {
                completion(true)
            }
        @unknown default:
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }

    private func presentNextViewController() {
        switch source {
        case .byRegisterVC:
            coordinator.presentChatsListNavigationController(withChatUser: chatUser)
        case .bySettingsVC:
            popViewController.accept(nil)
        }
    }

    // MARK: Objc private methods
    @objc private func shouldUpdateColors() {
        viewControllerBackgroundColor.accept(palette(.profileViewControllerBackgroundColor))
    }
}

// MARK: - extension + ProfileViewModelProtocol -
extension ProfileViewModel: ProfileViewModelProtocol {}

// MARK: - extension + ProfileViewModelInputProtocol -
extension ProfileViewModel: ProfileViewModelInputProtocol {
    func setImageActivityIndicatorDelegate(with delegate: ImageActivityIndicatorDelegate) {
        self.imageActivityIndicatorDelegate = delegate
    }
}

// MARK: - extension + ProfileViewModelOutputProtocol -
extension ProfileViewModel: ProfileViewModelOutputProtocol {}

// MARK: - ProfileViewModel + UIImagePickerControllerDelegate, UINavigationControllerDelegate -
extension ProfileViewModel: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        Logger.log(to: .info, message: "Изображение с камеры или библиотеки получено")
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else {
            Logger.log(to: .notice, message: "Не найдено изображение из библиотеки")
            return
        }

        imageActivityIndicatorDelegate?.showActivityIndicator()

        remoteFileStorageManager.uploadImage(image)
            .subscribe { [weak self] result in
                switch result {
                case .success(let userImageURLString):
                    Logger.log(to: .info, message: "Изображение загружено в firebase")
                    self?.userImageURLString = userImageURLString

                    self?.imageActivityIndicatorDelegate?.hideActivityIndicator()

                    self?.userImage = image
                    self?.reloadCellWithUserImage.accept(nil)
                case .failure: break
                }
            }
            .disposed(by: bag)
    }
}
