//
//  AppDelegate.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit
import Services

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebase
        Firebase.setupFirebase()

        // Facebook
        Facebook.setupFacebook(application: application,
                               didFinishLaunchingWithOptions: launchOptions)

        let window = UIWindow(frame: UIScreen.main.bounds)

        // Конфигурация приложения
        let configureManager = ConfigureManager()
        AppAssembly(window: window, configManager: configureManager)
        return true
    }

    // Для авторизации через гугл и facebool
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any])
      -> Bool {

          Facebook.setupFacebookURLHandler(application: application,
                                           open: url,
                                           sourceApplication: options)

          return Google.googleURLHandler(url)
    }
}
