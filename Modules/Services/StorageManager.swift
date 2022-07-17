//
//  StorageManager.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Logger
import Models
import RxSwift
import CoreData

private enum LocalConstants {
    static let coreDataModelName = "MyChat"
}

public enum UserType {
    case coreDataUser(CDChatUser)
    case chatUser(ChatUser)
}

public enum ContextType {
    case main
    case custom(NSManagedObjectContext)
}

public protocol StorageManagerProtocol {
    var backgroundContextForSaving: NSManagedObjectContext? { get }
    var backgroundContextNotForSaving: NSManagedObjectContext? { get }

    // Загрузка
    func fetchChat(chatID: String?,
                   from context: NSManagedObjectContext) -> Single<CDChat?>
    func fetchUser(userID: String,
                   from context: ContextType) -> Single<CDChatUser?>
    func fetchUser(chatID: String,
                   from context: ContextType) -> Single<CDChatUser?>
    func checkObjectCount<T: NSFetchRequestResult>(request: NSFetchRequest<T>) -> Int?
    func getChatsFetchResultsController() -> NSFetchedResultsController<CDChat>
    func getMessagesFetchResultsController(chatID: String) -> NSFetchedResultsController<CDMessage>

    // Создание
    func createChat(chatID: String,
                    receiverUser: UserType?,
                    in context: NSManagedObjectContext) -> CDChat
    // swiftlint:disable:next function_parameter_count
    func createMessage(action: MessageAction,
                       position: MessagePosition,
                       text: String,
                       target: CDTarget?,
                       sender: CDChatUser?,
                       in context: NSManagedObjectContext) -> CDMessage
    func createTarget(id: String,
                      in context: NSManagedObjectContext) -> CDTarget
    func createChatUser(id: String,
                        in context: NSManagedObjectContext) -> CDChatUser
    // Сохранение(обновление)
    func saveContext(with context: NSManagedObjectContext,
                     completion: ((Result<Any?, Error>) -> Void)?)

    func saveUser(with user: ChatUser) -> Single<Any?>
    // Удаление
    func remove(chat: CDChat) -> Single<Any?>
    func removeEverything() -> Single<Any?>
}

public final class StorageManager {

    // MARK: Public properties
    public var backgroundContextForSaving: NSManagedObjectContext?
    public var backgroundContextNotForSaving: NSManagedObjectContext? {
        container.newBackgroundContext()
    }

    // MARK: Private properties
    private var container: NSPersistentContainer = {

        guard let bundle = Bundle(identifier: "highlights.Models") else { return NSPersistentContainer() }
        guard let modelURL = bundle.url(forResource: "MyChat", withExtension: "momd") else {
            return NSPersistentContainer()
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            return NSPersistentContainer()
        }
        let container = NSPersistentContainer(name: LocalConstants.coreDataModelName,
                                              managedObjectModel: managedObjectModel)

        container.loadPersistentStores { _, error in
            if let error = error as? NSError {
                Logger.log(to: .critical,
                           message: "Не удалось загрузить PersistentStores",
                           error: error)
                fatalError("Не удалось загрузить PersistentStores")
            }
        }

        return container
    }()

    // MARK: Init
    public init() {
        backgroundContextForSaving = container.newBackgroundContext()
    }
}

// MARK: - extension + StorageManagerProtocol -
extension StorageManager: StorageManagerProtocol {

    // Создание
    public func createChat(chatID: String,
                           receiverUser: UserType?,
                           in context: NSManagedObjectContext) -> CDChat {
        let chat = CDChat(context: context)

        switch receiverUser {
        case .coreDataUser(let cdUser):
            chat.setupChat(chatID: chatID, receiverUser: cdUser)
            return chat
        case .chatUser(let user):
            let request = CDChatUser.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", user.id)
            do {
                let receiverUser = try context.fetch(request).first
                if let receiverUser = receiverUser {
                    chat.setupChat(chatID: chatID,
                                   receiverUser: receiverUser)
                    Logger.log(to: .info, message: "Создан чат с id \(chatID)")
                    return chat
                } else {
                    let newReceiverUser = CDChatUser(context: context)
                    newReceiverUser.setup(id: receiverUser?.id ?? "",
                                          name: receiverUser?.name ?? "-",
                                          email: receiverUser?.email ?? "",
                                          avatarURL: receiverUser?.avatarURL)
                    chat.setupChat(chatID: chatID, receiverUser: newReceiverUser)
                    return chat
                }
            } catch {
                Logger.log(to: .error, message: "Не удалось выгрузить юзера и создать чат", error: error)
                return chat
            }
        case .none:
            return chat
        }
    }

    public func createMessage(action: MessageAction,
                              position: MessagePosition,
                              text: String,
                              target: CDTarget? = nil,
                              sender: CDChatUser? = nil,
                              in context: NSManagedObjectContext) -> CDMessage {
        let message = CDMessage(context: context)
        message.setup(action: action,
                      position: position,
                      text: text,
                      target: target,
                      sender: sender)
        return message
    }

    public func createTarget(id: String,
                             in context: NSManagedObjectContext) -> CDTarget {
        let room = CDTarget(context: context)
        room.id = id
        return room
    }

    public func createChatUser(id: String,
                               in context: NSManagedObjectContext) -> CDChatUser {
        let user = CDChatUser(context: context)
        user.id = id
        return user
    }

    // Сохранение
    public func saveContext(with context: NSManagedObjectContext,
                            completion: ((Result<Any?, Error>) -> Void)?) {
        do {
            try context.save()
            completion?(.success(nil))
        } catch {
            Logger.log(to: .error, message: "Не удалось сохранить контекст core data", error: error)
            completion?(.failure(error))
        }
    }

    public func saveUser(with user: ChatUser) -> Single<Any?> {
        Single<Any?>.create { [saveContext, container] obs in
            let context = container.newBackgroundContext()
            let chatUser = CDChatUser(context: context)
            chatUser.id              = user.id
            chatUser.name            = user.name
            chatUser.email           = user.email
            chatUser.avatarURL       = user.avatarURL
            saveContext(context) { result in
                switch result {
                case .success:
                    Logger.log(to: .info, message: "Пользователь с id \(user.id) сохранен в бд")
                    obs(.success(nil))
                case .failure(let error):
                    Logger.log(to: .error, message: "Не удалось сохранить в бд пользователя с id \(user.id)",
                               error: error)
                    obs(.failure(error))
                }
            }
            return Disposables.create()
        }
    }

    // Загрузка из базы
    public func fetchChat(chatID: String?, from context: NSManagedObjectContext) -> Single<CDChat?> {
            let chatID = chatID ?? ""

            let request = CDChat.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", chatID)
            return fetchObject(with: request, context: context)
    }

    public func fetchUser(userID: String, from context: ContextType) -> Single<CDChatUser?> {
        var localContext = backgroundContextForSaving ?? container.newBackgroundContext()
            switch context {
            case .main: break
            case .custom(let context):
                localContext = context
            }
            let request = CDChatUser.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", userID)

        return fetchObject(with: request, context: localContext)
    }

    public func fetchUser(chatID: String,
                          from context: ContextType) -> Single<CDChatUser?> {
        var localContext = backgroundContextForSaving ?? container.newBackgroundContext()
        switch context {
        case .main: break
        case .custom(let context):
            localContext = context
        }
        let request = CDChatUser.fetchRequest()
        request.predicate = NSPredicate(format: "chat.id == %@", chatID)

        return fetchObject(with: request, context: localContext)
    }

    public func checkObjectCount<T: NSFetchRequestResult>(request: NSFetchRequest<T>) -> Int? {

        let context = container.newBackgroundContext()

        do {
            return try context.count(for: request)
        } catch {
            Logger.log(to: .error,
                       message: "Не удалось уточнить количество копий объекта в базе",
                       error: error)
            return nil
        }
    }

    // FetchResultsControllers
    public func getChatsFetchResultsController() -> NSFetchedResultsController<CDChat> {
        let request = CDChat.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "lastMessageDate", ascending: false)]
        return getFetchResultsController(with: request)
    }

    public func getMessagesFetchResultsController(chatID: String) -> NSFetchedResultsController<CDMessage> {
        let request = CDMessage.fetchRequest()
        request.predicate = NSPredicate(format: "chat.id == %@", chatID)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return getFetchResultsController(with: request)
    }

    // swiftlint:disable:next line_length
    public func getChatUsersFetchResultController(from context: NSManagedObjectContext) -> NSFetchedResultsController<CDChatUser> {
        let request = CDChatUser.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        return getFetchResultsController(with: request, context: context)
    }

    // Удаление
    public func remove(chat: CDChat) -> Single<Any?> {
        Single<Any?>.create { [weak self] obs in
            guard let backgroundContextForSaving =  self?.backgroundContextForSaving else { return Disposables.create()}
            backgroundContextForSaving.delete(chat)
            self?.saveContext(with: backgroundContextForSaving) { result in
                switch result {
                case .success:
                    obs(.success(nil))
                case .failure(let error):
                    obs(.failure(error))
                }
            }
            return Disposables.create()
        }
    }

    public func removeEverything() -> Single<Any?> {
        Single<Any?>.create { [weak self] obs in

            guard let storeCoordinator = self?.container.persistentStoreCoordinator else { return Disposables.create() }
            for store in storeCoordinator.persistentStores {
                do {
                    guard let url = store.url else { return  Disposables.create() }
                    try self?.backgroundContextForSaving?.save()
                    try storeCoordinator.destroyPersistentStore(at: url, ofType: store.type)
                    obs(.success(nil))
                } catch {
                    obs(.failure(error))
                }
            }

            guard let bundle = Bundle(identifier: "highlights.Models") else { return Disposables.create() }
            guard let modelURL = bundle.url(forResource: "MyChat", withExtension: "momd") else {
                return Disposables.create()
            }

            guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
                return Disposables.create()
            }
            self?.container = NSPersistentContainer(name: LocalConstants.coreDataModelName,
                                                    managedObjectModel: managedObjectModel)

            self?.container.loadPersistentStores { _, error in
                if let error = error as? NSError {
                    Logger.log(to: .critical,
                               message: "Не удалось загрузить PersistentStores",
                               error: error)
                    fatalError("Не удалось загрузить PersistentStores")
                }
                self?.backgroundContextForSaving = self?.container.newBackgroundContext()
            }

            return Disposables.create()
        }
    }

    // MARK: Private methods
    private func fetchObject<T: NSManagedObject>(with request: NSFetchRequest<T>,
                                                 context: NSManagedObjectContext) -> Single<T?> {
        Single<T?>.create { obs in
            do {
                let user = try context.fetch(request).first
                obs(.success(user))
            } catch {
                obs(.failure(error))
            }
            return Disposables.create()
        }
    }

    private func getFetchResultsController<T>(with request: NSFetchRequest<T>,
                                              context: NSManagedObjectContext? = nil) -> NSFetchedResultsController<T> {
        var localContext: NSManagedObjectContext?

        if let context = context {
            localContext = context
        } else {
            localContext = backgroundContextForSaving
        }

        localContext = context == nil ? backgroundContextForSaving : context
        guard let localContext = localContext else {
            return NSFetchedResultsController()
        }
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                                  managedObjectContext: localContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        do {
            try fetchedResultsController.performFetch()
        } catch {
            Logger.log(to: .error, message: "Не удалось завести fetchedResultsController", error: error)
        }
        return fetchedResultsController
    }
}
