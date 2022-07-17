//
//  Target.swift
//  Models
//
//  Created by Boris Verbitsky on 31.05.2022.
//

import Foundation

public struct Target: Decodable {

    // MARK: Public properties
    public let id: String

    // MARK: Init
    public init(id: String) {
        self.id = id
    }

    public init(coreDataTarget: CDTarget) {
        self.id = coreDataTarget.id
    }
}
