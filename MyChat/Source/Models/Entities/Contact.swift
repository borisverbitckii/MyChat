//
//  Sender.swift
//  MyChat
//
//  Created by Boris Verbitsky on 05.04.2022.
//

struct Contact {
    let name: String
    let surname: String
    var nameAndSurname: String {
        return name + " " + surname
    }
    let userIcon: String
}
