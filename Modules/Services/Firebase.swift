//
//  Firebase.swift
//  Services
//
//  Created by Boris Verbitsky on 11.04.2022.
//

import Firebase

public final class Firebase {

    // MARK: Public Methods
    public static func setupFirebase() {
        FirebaseApp.configure()
    }
}
