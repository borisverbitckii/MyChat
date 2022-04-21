//
//  NSObject + className.swift
//  MyChat
//
//  Created by Boris Verbitsky on 21.04.2022.
//

import Foundation

extension NSObject {
    var className: String {
        return NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
    }
}
