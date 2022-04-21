//
//  UIViewController + swizzling.swift
//  MyChat
//
//  Created by Boris Verbitsky on 21.04.2022.
//

import UIKit
import AsyncDisplayKit
import Logger

extension UIViewController {

    @objc func viewDidAppearOverride(_ animated: Bool) {
        if let controller = self as? UIAlertController {
            Logger.log(to: .info, message: "Презентован и отображен \(className)",
                       messageDescription: controller.message)
            return
        }
        Logger.log(to: .info, message: "Презентован и отображен \(className)")
    }

    static func swizzleViewDidAppear() {
        let originalSelector = #selector(UIViewController.viewDidAppear(_:))
        let swizzledSelector = #selector(UIViewController.viewDidAppearOverride(_:))
        guard let originalMethod = class_getInstanceMethod(self, originalSelector),
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector) else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}
