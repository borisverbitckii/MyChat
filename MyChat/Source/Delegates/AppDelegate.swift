//
//  AppDelegate.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit
import Firebase
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        let window = UIWindow(frame: UIScreen.main.bounds)
        let configureManager = ConfigureManager()
        // swiftlint:disable:next redundant_discardable_let
        let _ = AppAssembly(window: window, configManager: configureManager)
        return true
    }

    // Для авторизации через гугл
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any])
      -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
}
