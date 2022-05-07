//
//  ViewModel.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Models
import Logger
import RxSwift
import RxRelay
import Services
import CoreData
import Messaging

protocol ChatsListViewModelProtocol {
    var input: ChatsListViewModelInput { get }
    var output: ChatsListViewModelOutput { get }
}

protocol ChatsListViewModelInput {
    func getChatsCount(section: Int) -> Int

    func createChatRoom(withChatAt indexPath: IndexPath, presenterVC: TransitionHandler)
}

protocol ChatsListViewModelOutput {
    var fetchResultsController: NSFetchedResultsController<Chat> { get }
    var chatsCollectionShouldReload: PublishRelay<Any?> { get }
    func chatForIndexPath(indexPath: IndexPath) -> Chat

    // UI
    var viewControllerBackgroundColor: BehaviorRelay<UIColor> { get }
    var titleText: BehaviorRelay<String> { get }
    var titleFont: BehaviorRelay<UIFont> { get }

}

final class ChatsListViewModel {

    // MARK: Public properties
    var input: ChatsListViewModelInput { return self }
    var output: ChatsListViewModelOutput { return self }

    var chatsCollectionShouldReload = PublishRelay<Any?>()

    // UI
    var viewControllerBackgroundColor: BehaviorRelay<UIColor>
    var titleText: BehaviorRelay<String>
    var titleFont: BehaviorRelay<UIFont>

    // MARK: Private properties
    private let coordinator: CoordinatorProtocol
    private let chatsCoordinator: ChatsFlowProtocol
    private(set) var fetchResultsController: NSFetchedResultsController<Chat> // TODO: Подумать, возможно вынести из ChatsFlowCoordinatorProtocol

    private let fonts: (ChatsListViewControllerFonts) -> UIFont
    private let texts: (ChatsListViewControllerTexts) -> String
    private let palette: (ChatsListViewControllerPalette) -> UIColor

    private lazy var bag = DisposeBag()

    // MARK: Init
    init(user: ChatUser,
         coordinator: CoordinatorProtocol,
         webSocketsFacade: WebSocketsFlowFacade,
         fonts: @escaping (ChatsListViewControllerFonts) -> UIFont,
         texts: @escaping (ChatsListViewControllerTexts) -> String,
         palette: @escaping (ChatsListViewControllerPalette) -> UIColor) {
        self.coordinator = coordinator

        self.chatsCoordinator = webSocketsFacade
        webSocketsFacade.setupConnectionWith(userID: user.userID)
        self.fetchResultsController = webSocketsFacade.getChatsFetchResultsController()

        self.fonts = fonts
        self.texts = texts
        self.palette = palette

        // Настройка цветов
        let vcBackgroundColor = palette(.chatsListViewControllerBackgroundColor)
        self.viewControllerBackgroundColor = BehaviorRelay<UIColor>(value: vcBackgroundColor)

        // Настройка текстов
        let text = texts(.title)
        self.titleText = BehaviorRelay<String>(value: text)

        // Настройка шрифтов
        let font = fonts(.empty) // TODO: - Убрать
        self.titleFont = BehaviorRelay<UIFont>(value: font)

        let dataBase = RemoteDataBaseManager()
        dataBase.saveUserData(with: user)
            .subscribe { [bag] result in
                switch result {
                case .success:
                    dataBase.fetchUsersUUIDs(email: "990")
                        .subscribe { users in
                            print(users)
                        } onFailure: { error in
                            print(error)
                        }
                        .disposed(by: bag)
                case .failure: break
                }
            }
            .disposed(by: bag)
    }
}

// MARK: - extension + ChatsListViewModelProtocol -
extension ChatsListViewModel: ChatsListViewModelProtocol {

}

// MARK: - extension + ChatsListViewModelInput -
extension ChatsListViewModel: ChatsListViewModelInput {

    func createChatRoom(withChatAt indexPath: IndexPath, presenterVC: TransitionHandler) {
        let id = 123456 // TODO: - Убрать
        chatsCoordinator.joinPrivateRoom(chatID: "\(id)") { result in
            switch result {
            case .success:
                Logger.log(to: .info, message: "Комната с id \(id) успешно создана")
            case .failure(let error):
                Logger.log(to: .error, message: "Не удалось создать команту с id \(id)", error: error)
            }
        }
    }
}

// MARK: - extension + ChatsListViewModelOutput -
extension ChatsListViewModel: ChatsListViewModelOutput {

    // MARK: Public methods
    func chatForIndexPath(indexPath: IndexPath) -> Chat {
        fetchResultsController.object(at: indexPath)
    }

    func getChatsCount(section: Int) -> Int {
        let sectionInfo = fetchResultsController.sections?[section]
        return sectionInfo?.numberOfObjects ?? 0
    }
}
