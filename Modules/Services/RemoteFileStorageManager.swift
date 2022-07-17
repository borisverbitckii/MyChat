//
//  RemoteFileStorage.swift
//  Services
//
//  Created by Boris Verbitsky on 27.06.2022.
//

import Logger
import RxSwift
import FirebaseStorage

public protocol RemoteFileStorageManagerProtocol {
    func uploadImage(_ image: UIImage) -> Single<String?>
}

public final class RemoteFileStorageManager {

    // MARK: Private properties
    private lazy var store = Storage.storage().reference()

    // MARK: Init
    public init() {}
}

// MARK: - extension + RemoteFileStorageProtocol -
extension RemoteFileStorageManager: RemoteFileStorageManagerProtocol {

    public func uploadImage(_ image: UIImage) -> Single<String?> {
        Single<String?>.create { [store] obs in
            guard let imageData = image.jpegData(compressionQuality: 0.5 ) else { return Disposables.create() }
            let imageRef = store.child("usersImages/image\(UUID().uuidString).jpg")
            imageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    Logger.log(to: .error, message: "Не удалось выгрузить изображение в удаленное хранилище",
                               error: error)
                    obs(.failure(error))
                    return
                }
                imageRef.downloadURL { url, error in
                    if let error = error {
                        Logger.log(to: .error, message: "Не удалось получить ссылку на изображение", error: error)
                        obs(.failure(error))
                        return
                    }
                    guard let url = url else {
                        Logger.log(to: .error, message: "Не удалось получить ссылку на изображение")
                        obs(.failure(NSError(domain: "Не удалось получить ссылку на изображение",
                                             code: 0 )))
                        return
                    }
                    obs(.success(url.absoluteString))
                }

            }
            return Disposables.create()
        }
    }
}
