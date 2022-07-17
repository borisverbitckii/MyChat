//
//  MessagePosition.swift
//  Models
//
//  Created by Boris Verbitsky on 08.06.2022.
//

import Foundation

@objc public enum MessagePosition: Int16, Decodable {
    case left = 0
    case right = 1
    case noPosition = 3
}
