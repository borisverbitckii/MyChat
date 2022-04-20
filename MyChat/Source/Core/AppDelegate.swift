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
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: Public properties
    var window: UIWindow?

    // MARK: Private properties
    private var appAssembly: AppAssembly?

    private lazy var globalManagerFactory: ManagerFactoryGlobalProtocol = ManagerFactory()
    private lazy var configManager: ConfigureManagerProtocol = {
        globalManagerFactory.getConfigManager()
    }()
    private lazy var pushNotificationsManager: PushNotificationManagerProtocol = {
        globalManagerFactory.getPushNotificationManager()
    }()

    // MARK: Public Methods
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebase
        Firebase.setupFirebase()

        // Facebook
        Facebook.setupFacebook(application: application,
                               didFinishLaunchingWithOptions: launchOptions)

        // Конфигурация приложения
        let window = UIWindow(frame: UIScreen.main.bounds)
        appAssembly = AppAssembly(window: window, configManager: configManager)
        pushNotificationsManager.pushNotificationHandler = appAssembly?.pushNotificationHandler

        // Настройки для получения push уведомлений
        pushNotificationsManager.configureApp(application: application,
                                              pushNotificationCenterDelegate: self,
                                              messagingDelegate: self)
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

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // swiftlint:disable:next control_statement
        if (userInfo.index(forKey: "CONFIG_STATE") != nil) {
            UserDefaults.standard.set(true, forKey: "CONFIG_STALE")
            let pushNotificationHandler = pushNotificationsManager.pushNotificationHandler
            guard let pushNotificationHandler = pushNotificationHandler else {
                assertionFailure(AssertionErrorMessages.noPushNotificationHandler.assertionErrorMessage)
                return
            }
            pushNotificationHandler()
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
}

/// Для получения новых appConfig в реальном времени
extension AppDelegate: MessagingDelegate {

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        messaging.subscribe(toTopic: "PUSH_RC") { error in
            if let error = error {
                print(error) // TODO: Залогировать
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
}
