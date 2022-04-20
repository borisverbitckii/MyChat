//
//  PushNotificationManager.swift
//  Services
//
//  Created by Boris Verbitsky on 19.04.2022.
//

import UIKit
import FirebaseMessaging

public protocol PushNotificationManagerProtocol {
    /// Клоужер для обработки push нотификаций и обновления конфига
    var pushNotificationHandler: (() -> Void)? { get set }
    func configureApp(application: UIApplication,
                      pushNotificationCenterDelegate: UNUserNotificationCenterDelegate?,
                      messagingDelegate: MessagingDelegate?)
}

public final class PushNotificationManager {
    
    // MARK: Public properties
    public var pushNotificationHandler: (() -> Void)?

    public init() {}
}

extension PushNotificationManager: PushNotificationManagerProtocol {

    // MARK: Public Methods
    public func configureApp(application: UIApplication,
                      pushNotificationCenterDelegate: UNUserNotificationCenterDelegate?,
                      messagingDelegate: MessagingDelegate?) {

        UNUserNotificationCenter.current().delegate = pushNotificationCenterDelegate
        Messaging.messaging().delegate = messagingDelegate

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, error in
                if let error = error {
                    print(error) // TODO: Залогировать ошибку
                }
            })

        application.registerForRemoteNotifications()
    }
}
