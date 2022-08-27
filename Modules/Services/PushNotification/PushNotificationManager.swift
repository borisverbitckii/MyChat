//
//  PushNotificationManager.swift
//  Services
//
//  Created by Boris Verbitsky on 19.04.2022.
//

import UIKit
import Logger
import FirebaseMessaging

public protocol PushNotificationManagerProtocol {
    /// Клоужер для обработки push нотификаций и обновления конфига
    var pushNotificationHandler: (() -> Void)? { get set }
    func configureApp(application: UIApplication)
}

public final class PushNotificationManager {

    // MARK: Public properties
    public var pushNotificationHandler: (() -> Void)?

    // MARK: Private properties
    private lazy var messagingDelegateImpl = MessagingDelegateImpl()

    // MARK: Init
    public init() {}
}

extension PushNotificationManager: PushNotificationManagerProtocol {

    // MARK: Public Methods
    public func configureApp(application: UIApplication) {

        UNUserNotificationCenter.current().delegate = messagingDelegateImpl
        Messaging.messaging().delegate = messagingDelegateImpl

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, error in
                if let error = error {
                    Logger.log(to: .error,
                               message: "Не удалось получить разрешение на пуши",
                               error: error)
                }
            })

        application.registerForRemoteNotifications()
    }
}
