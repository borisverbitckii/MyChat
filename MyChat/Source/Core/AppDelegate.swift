//
//  AppDelegate.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import UIKit
import RxRelay
import Services
import Models

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: Public properties
    var window: UIWindow?

    // MARK: Private properties
    private var appAssembly: AppAssembly?

    // MARK: Public Methods
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebase
        Firebase.setupFirebase()

        // Facebook
        Facebook.setupFacebook(application: application,
                               didFinishLaunchingWithOptions: launchOptions)

        let window = UIWindow(frame: UIScreen.main.bounds)

        // Конфигурация приложения
        let configureManager: ConfigureManagerProtocol = ConfigureManager()
        appAssembly = AppAssembly(window: window, configManager: configureManager)
        return true
    }

    // Для авторизации через google и facebook
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {

        Facebook.setupFacebookURLHandler(application: application,
                                         open: url,
                                         sourceApplication: options)

        return Google.googleURLHandler(url)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        appAssembly?.uiConfigObserverDisposable?.dispose()
    }
}
