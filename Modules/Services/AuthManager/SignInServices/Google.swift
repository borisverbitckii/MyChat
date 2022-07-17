//
//  Google.swift
//  Services
//
//  Created by Boris Verbitsky on 11.04.2022.
//

import GoogleSignIn

public final class Google {

    // MARK: Public properties
    public static let googleURLHandler: (URL) -> (Bool) = { url in
        GIDSignIn.sharedInstance.handle(url)
    }
}
