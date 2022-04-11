//
//  Facebook.swift
//  Services
//
//  Created by Boris Verbitsky on 11.04.2022.
//

import FBSDKLoginKit

public final class Facebook {

    // MARK: Public Methods
    public static func setupFacebook(application: UIApplication,
                                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    }

    public static func setupFacebookURLHandler(application: UIApplication,
                                               open url: URL,
                                               sourceApplication options: [UIApplication.OpenURLOptionsKey: Any]) {
        ApplicationDelegate.shared.application(
            application,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
}
