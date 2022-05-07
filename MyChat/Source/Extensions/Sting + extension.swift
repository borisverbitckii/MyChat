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

    func decode(with context: NSManagedObjectContext) -> [Message]? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        let decoder = JSONDecoder()
        decoder.userInfo[.context!] = context

        do {
            return try decoder.decode([Message].self, from: data)
        } catch {
            Logger.log(to: .error, message: "Не удалось декодировать строку в Message", error: error)
            return nil
        }
    }
}
