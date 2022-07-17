//
//  ContactCellModel.swift
//  Models
//
//  Created by Boris Verbitsky on 05.06.2022.
//

import UIKit

public struct ContactCellModel {
    public let name: String
    public let nameColor: UIColor
    public let email: String

    public init(name: String,
                nameColor: UIColor,
                email: String) {
        self.name = name
        self.nameColor = nameColor
        self.email = email
    }
}
