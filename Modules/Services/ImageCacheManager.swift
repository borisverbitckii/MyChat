//
//  ImageCacheManager.swift
//  Services
//
//  Created by Boris Verbitsky on 04.06.2022.
//

import Logger
import RxSwift

import Foundation

public protocol ImageCacheManagerProtocol {
    func fetchImage(urlString: String) -> Single<UIImage?>
}

public final class ImageCacheManager {

    // MARK: Init
    public init() {}
}

// MARK: - extension + ImageCacheManagerProtocol -
extension ImageCacheManager: ImageCacheManagerProtocol {

    public func fetchImage(urlString: String) -> Single<UIImage?> {
        Single<UIImage?>.create { [weak self] obs in
            guard let url = URL(string: urlString) else {
                obs(.success(nil))
                return Disposables.create()}

            if let image = self?.getCacheImage(url: url) {
                DispatchQueue.main.async {
                    obs(.success(image))
                }
                return Disposables.create()
            }

            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    obs(.failure(error))
                    return
                }
                guard let data = data,
                      let response = response else { return }

                self?.saveImageToCache(imageData: data, response: response)
                DispatchQueue.main.async {
                    obs(.success(UIImage(data: data)))
                }
            }.resume()

            return Disposables.create()
        }
    }

    // MARK: Private methods

    private func saveImageToCache(imageData: Data, response: URLResponse) {
        guard let responseURL = response.url else { return }
        let cachedResponse = CachedURLResponse(response: response, data: imageData)
        URLCache.shared.storeCachedResponse(cachedResponse, for: URLRequest(url: responseURL))
    }

    private func getCacheImage(url: URL) -> UIImage? {
        if let cacheResponce = URLCache.shared.cachedResponse(for: URLRequest(url: url)) {
            return UIImage(data: cacheResponce.data)
        }

        return nil
    }
}
