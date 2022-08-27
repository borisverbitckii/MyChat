//
//  MessagingDelegateImpl.swift
//  Services
//
//  Created by Boris Verbitsky on 26.08.2022.
//

import Logger
import FirebaseMessaging

final class MessagingDelegateImpl: NSObject {}

extension MessagingDelegateImpl: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        messaging.subscribe(toTopic: "PUSH_RC") { error in
            if let error = error {
                Logger.log(to: .error,
                           message: error.localizedDescription,
                           error: error)
            }
        }
    }
}

extension MessagingDelegateImpl: UNUserNotificationCenterDelegate {}
