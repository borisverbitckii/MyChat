//
//  RemoteDataBaseManager.swift
//  Services
//
//  Created by Boris Verbitsky on 03.05.2022.
//

import Logger
import Models
import RxSwift
import Foundation
import FirebaseAuth
import FirebaseDatabase

public protocol RemoteDataBaseManagerProtocol {
    func saveUserData(with user: ChatUser) -> Single<Any?>
    func fetchUsersUUIDs(email: String) -> Single<[ChatUser]>
    func fetchUser(uuid: String) -> Single<ChatUser?>
}

public final class RemoteDataBaseManager {

    // MARK: Private properties
    private lazy var directDatabasePath: DatabaseReference =  {
        Database
            .database()
            .reference()
            .child("users/")
    }()

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

    public func fetchUser(uuid: String) -> Single<ChatUser?> {
        let query = directDatabasePath
            .queryOrdered(byChild: "userID")
            .queryEqual(toValue: uuid)
        return Single<ChatUser?>.create { [weak self] obs in
            let xxx = self?.fetchUsers(with: query)
                .subscribe { users in
                    guard let user = users.first else {
                        obs(.success(nil))
                        return
                    }
                    obs(.success(user))
                } onFailure: { error in
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

    // MARK: Private methods
    private func fetchUsers(with query: DatabaseQuery) -> Single<[ChatUser]> {
        Single<[ChatUser]>.create { obs in

            query.observeSingleEvent(of: .value) { snapshot in
                guard var json = snapshot.value as? [String: Any] else { return obs(.success([ChatUser]())) }

                do {
                    var users = [ChatUser]()
                    for (key, value) in json {
                        json["id"] = key
                        let chatUserData = try JSONSerialization.data(withJSONObject: value)
                        let chatUser = try JSONDecoder().decode(ChatUser.self, from: chatUserData)
                        if chatUser.userID == AuthManager.currentUser?.uid {
                            continue
                        }
                        users.append(chatUser)
                    }

                    users = users.sorted { $0.email ?? "" > $1.email ?? ""}

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
