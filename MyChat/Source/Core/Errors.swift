//
//  Errors.swift
//  MyChat
//
//  Created by Boris Verbitsky on 08.04.2022.
//

import Foundation

public enum Errors: Swift.Error, LocalizedError {
    case elementWithoutText
    case cantCheckIsLoggedInOrNot
}
