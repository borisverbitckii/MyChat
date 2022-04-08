//
//  Message.swift
//  MyChat
//
//  Created by Борис on 12.02.2022.
//

import Foundation

struct Message {
    let sender: Contact
    let text: String
    let time: Date
    var isRead: Bool
}
