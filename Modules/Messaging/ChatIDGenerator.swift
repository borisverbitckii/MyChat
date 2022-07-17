//
//  ChatIDGenerator.swift
//  Messaging
//
//  Created by Boris Verbitsky on 03.05.2022.
//

import Foundation

/*Специальный генератор chatID, который смешивает
id пользователя телефона и id пользователя,
с которым будет начат диалог*/

public final class ChatIDGenerator {
    public static func generateChatID(phoneUserID: String, targetUserID: String) -> String {

        var isPhoneUserIDIsBigger = false

        // Определяется, у кого первый символ будет больше
        for index in 0..<phoneUserID.count {
            if phoneUserID[index] != targetUserID[index] {
                isPhoneUserIDIsBigger = phoneUserID[index] > targetUserID[index]
                break
            }
        }

        // Генерируется сам chatID
        var chatID = ""

        if isPhoneUserIDIsBigger {
            for index in 0..<phoneUserID.count {
                // В результате символы смешиваются поочередно
                chatID += phoneUserID[index]
                chatID += targetUserID[index]
            }
        } else {
            for index in 0..<phoneUserID.count {
                chatID += targetUserID[index]
                chatID += phoneUserID[index]
            }
        }

        return chatID
    }
}

public extension String {
    subscript(idx: Int) -> String {
        String(self[index(startIndex, offsetBy: idx)])
    }
}
