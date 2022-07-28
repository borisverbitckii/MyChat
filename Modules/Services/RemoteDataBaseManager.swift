//
//  RemoteDataBaseManager.swift
//  Services
//
//  Created by Boris Verbitsky on 03.05.2022.
//

import Logger
import Models
import RxSwift
import CoreData
import Foundation
import FirebaseAuth
import FirebaseDatabase

public enum FetchType {
    case all
    case selfUser
}

public protocol RemoteDataBaseManagerProtocol {
    func saveUserData(with user: ChatUser) -> Single<Any?>
    func fetchUser(fetchType: FetchType, id: String) -> Single<ChatUser?>
    func fetchUsersUUIDs(email: String) -> Single<[ChatUser]>
    func updateUser(id: String, name: String, userIconURLString: String?) -> Single<Any?>
    func removeUser(id: String) -> Single<Any?>
}

public final class RemoteDataBaseManager {

    // MARK: Private properties
    private let directDatabasePath: DatabaseReference =  {
        Database
            .database()
            .reference()
            .child("users/")
    }()
    private lazy var bag = DisposeBag()

    private var usersDatabasePath: DatabaseReference? {
        guard let uuid = AuthManager.currentUser?.uid else { return nil }
        return directDatabasePath
            .child("\(uuid)")
    }

    // MARK: Init
    public init() {}
}

// MARK: - extension + RemoteDataBaseManagerProtocol -
extension RemoteDataBaseManager: RemoteDataBaseManagerProtocol {

    // MARK: Public Methods
    public func saveUserData(with user: ChatUser) -> Single<Any?> {
        Single<Any?>.create { [usersDatabasePath] obs in
            do {
                let data = try JSONEncoder().encode(user)
                let json = try JSONSerialization.jsonObject(with: data)

                usersDatabasePath?.setValue(json) { error, _ in
                    if let error = error {
                        Logger.log(to: .error,
                                   message: "Не удалось отправить данные в базу данных firebase",
                                   error: error)
                        obs(.failure(error))
                    }
                    Logger.log(to: .info, message: "Данные о пользователе отправлены в базу данных firebase")
                    obs(.success(nil))
                }
            } catch {
                Logger.log(to: .error, message: "Не удалось отправить данные в базу данных firebase", error: error)
                obs(.failure(error))
            }
            return Disposables.create()
        }
    }

    public func fetchUsersUUIDs(email: String) -> Single<[ChatUser]> {
        let email = email.lowercased()
        let query = directDatabasePath
            .queryOrdered(byChild: "email")
            .queryStarting(atValue: email)
            .queryEnding(atValue: email + "~")
        return fetchUsers(with: query)
    }

    public func fetchUser(fetchType: FetchType = .all, id: String) -> Single<ChatUser?> {
        let query = directDatabasePath
            .queryOrdered(byChild: "id")
            .queryStarting(atValue: id)
            .queryEnding(atValue: id + "~")
        return Single<ChatUser?>.create { [weak self, bag] obs in
            self?.fetchUsers(type: fetchType, with: query)
                .subscribe { users in
                    obs(.success(users.first))
                } onFailure: { error in
                    obs(.failure(error))
                }
                .disposed(by: bag)
            return Disposables.create()
        }
    }

    public func updateUser(id: String, name: String,
                           userIconURLString: String? = nil) -> Single<Any?> {
        Single<Any?>.create { [directDatabasePath] obs in
            directDatabasePath.child(id).updateChildValues(["name": name,
                                                            "avatarURL": userIconURLString ?? ""]) { error, _ in
                if let error = error {
                    Logger.log(to: .error,
                               message: "Не удалось обновить данные пользователя",
                               error: error)
                    obs(.failure(error))
                    return
                }
                obs(.success(nil))
            }
            return Disposables.create()
        }
    }

    public func removeUser(id: String) -> Single<Any?> {
        Single<Any?>.create { [directDatabasePath] obs in
            directDatabasePath.child("\(id)").removeValue { error, _ in
                if let error = error {
                    obs(.failure(error))
                    return
                }
                obs(.success(nil))
            }
            return Disposables.create()
        }
    }

    // MARK: Private methods
    private func fetchUsers(type: FetchType? = .all, with query: DatabaseQuery) -> Single<[ChatUser]> {
        Single<[ChatUser]>.create { obs in
            query.observeSingleEvent(of: .value) { snapshot in
                guard var json = snapshot.value as? [String: Any] else { return }
                do {
                    var users = [ChatUser]()

                    for (key, value) in json {
                        json["id"] = key
                        let chatUserData = try JSONSerialization.data(withJSONObject: value)

                        /// Decode
                        let decoder = JSONDecoder()
                        let chatUser = try decoder.decode(ChatUser.self, from: chatUserData)

                        /// Проверка, является ли пользователь сам собой в поиске
                        if chatUser.id == AuthManager.currentUser?.uid {
                            switch type {
                            case .all:
                                continue
                            default: break
                            }
                        }
                        users.append(chatUser)
                    }

                    users = users.sorted { $0.email > $1.email }

                    Logger.log(to: .info, message: "Данные о пользователях скачаны с firebase")
                    obs(.success(users))
                } catch {
                    Logger.log(to: .error, message: "Не удалось загрузить данные с базы данных firebase", error: error)
                    obs(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
