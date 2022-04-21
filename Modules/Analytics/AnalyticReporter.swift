//
//  AnalyticReporter.swift
//  Analytics
//
//  Created by Boris Verbitsky on 21.04.2022.
//

import FirebaseAnalytics

public enum AnalyticsEventType {
    case login(loginMethod: String)
    case signup(signupMethod: String)
    case signOut
    case custom(eventName: String)
}

public final class AnalyticReporter {

    public static func logEvent(_ event: AnalyticsEventType, parameters: [String: Any]? = nil) {
        switch event {
        case .login(let method):
            Analytics.logEvent(AnalyticsEventLogin, parameters: [AnalyticsParameterMethod: method])
        case .signup(let method):
            Analytics.logEvent(AnalyticsEventSignUp, parameters: [AnalyticsParameterMethod: method])
        case .custom(let eventName):
            Analytics.logEvent(eventName, parameters: parameters)
        case .signOut:
            Analytics.logEvent("sign_out", parameters: nil)
        }
    }

    public static func setUserID(_ userID: String?) {
        Analytics.setUserID(userID)
    }
}
