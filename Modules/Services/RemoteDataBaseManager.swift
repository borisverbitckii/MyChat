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
        Single<[ChatUser]>.create { [directDatabasePath] obs in
            let query = directDatabasePath.queryOrdered(byChild: "email").queryStarting(atValue: email)

            query.observeSingleEvent(of: .value) { snapshot in
                guard var json = snapshot.value as? [String: Any] else { return }

                do {
                    var users = [ChatUser]()
                    for (key, value) in json {
                        json["id"] = key
                        let chatUserData = try JSONSerialization.data(withJSONObject: value)
                        let chatUser = try JSONDecoder().decode(ChatUser.self, from: chatUserData)
                        users.append(chatUser)
                    }

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
