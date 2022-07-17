//
//  Sting + decode.swift
//  MyChat
//
//  Created by Boris Verbitsky on 05.05.2022.
//

import Models
import Logger
import Services
import CoreData
import Foundation

public extension String {

    func decode() -> [ReceivedMessage]? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        let decoder = JSONDecoder()
        do {
            return try decoder.decode([ReceivedMessage].self, from: data)
        } catch {
            Logger.log(to: .error, message: "Не удалось декодировать строку в Message", error: error)
            return nil
        }
    }
}
