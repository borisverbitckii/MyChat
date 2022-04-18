//
//  Reactive + extention.swift
//  MyChat
//
//  Created by Boris Verbitsky on 18.04.2022.
//

import RxSwift
import UIKit

extension Reactive where Base == UIScreen {

    func userInterfaceStyle() -> Observable<UIUserInterfaceStyle> {
        let currentUserInterfaceStyle = UITraitCollection.current.userInterfaceStyle
        let initial = Observable.just(currentUserInterfaceStyle)
        let selector = #selector(UIScreen.traitCollectionDidChange(_:))
        let following = base
            .rx
            .methodInvoked(selector)
            .flatMap { (_) -> Observable<UIUserInterfaceStyle> in
                return Observable.just(UITraitCollection.current.userInterfaceStyle)
        }
        return Observable.concat(initial, following)
    }
}
