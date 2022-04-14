//
//  Utils.swift
//  MyChat
//
//  Created by Boris Verbitsky on 14.04.2022.
//

/// Утилиты, которые можно вызывать статически из любой части приложения
enum Utils {

    static func validate(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }

    static func validate(password: String) -> Bool {
        let passwordRegEx = "[0-9a-zA-Z!@#$%^&*()\\-_=+{}|?>.<,:;~`’]{6,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordPredicate.evaluate(with: password)
    }
}
