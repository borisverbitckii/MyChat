//
//  Profile.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Foundation

struct Profile: Codable {

    let profileID: String
    let name: String
    let surname: String
    let avatar: Data

}
