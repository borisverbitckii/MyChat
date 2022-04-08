//
//  ViewModel.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import RxRelay
import CoreAudio

protocol ChatsListViewModelProtocol {
    var input: ChatsListViewModelInput { get }
    var output: ChatsListViewModelOutput { get }

}

protocol ChatsListViewModelInput {

}

protocol ChatsListViewModelOutput {
    var chatsCount: Int { get }
    func chatForIndexPath(index: Int) -> Chat
    var titleText: BehaviorRelay<String> { get }
    var titleFont: BehaviorRelay<UIFont> { get }
}

final class ChatsListViewModel {

    // MARK: Public properties
    var input: ChatsListViewModelInput { return self }
    var output: ChatsListViewModelOutput { return self }

    var chatsCount: Int {
        chats.count
    }

    var titleText: BehaviorRelay<String>
    var titleFont: BehaviorRelay<UIFont>

    // MARK: Private properties
    private let coordinator: CoordinatorProtocol
    private let networkManager: NetworkManagerChatListProtocol
    private let fonts: (ChatsListViewControllerFonts) -> UIFont
    private let texts: (ChatsListViewControllerTexts) -> String

    private let chats = [Chat]()

    // MARK: Init
    init(coordinator: CoordinatorProtocol,
         networkManager: NetworkManagerChatListProtocol,
         fonts: @escaping (ChatsListViewControllerFonts) -> UIFont,
         texts: @escaping (ChatsListViewControllerTexts) -> String) {
        self.coordinator = coordinator
        self.networkManager = networkManager
        self.fonts = fonts
        self.texts = texts

        let text = texts(.title)
        self.titleText = BehaviorRelay<String>(value: text)

        let font = fonts(.empty) // TODO: - Убрать
        self.titleFont = BehaviorRelay<UIFont>(value: font)
    }
}

// MARK: - extension + ChatsListViewModelProtocol -
extension ChatsListViewModel: ChatsListViewModelProtocol {

}

// MARK: - extension + ChatsListViewModelInput -
extension ChatsListViewModel: ChatsListViewModelInput {

}

// MARK: - extension + ChatsListViewModelOutput -
extension ChatsListViewModel: ChatsListViewModelOutput {

    // MARK: Public methods
    func chatForIndexPath(index: Int) -> Chat {
        return chats[index]
    }
}
