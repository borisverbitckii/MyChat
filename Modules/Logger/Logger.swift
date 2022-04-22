//
//  Logger.swift
//  Logger
//
//  Created by Boris Verbitsky on 20.04.2022.
//

import Analytics
import FirebaseCrashlytics

/// Режимы для логгера: печатать только сообщения или нет
public enum LoggerPrintingMode {
    case onlyMessages
    case print(Set<LoggerPrintElements>)
}

/// Элементы для выведения в консоль
public enum LoggerPrintElements {
    case file, function, line
}

/// Виды сообщений
public enum LogType {
    case debug, info, notice, warning, error, critical
}

public final class Logger {

    // MARK: Public properties

    /// Адрес log.txt
    public static var logsURL: URL {
        var logsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        logsURL.appendPathComponent("log.txt")
        return logsURL
    }

    /// Текст всех логов и файла
    public static var logs: String {
        do {
            return try String(contentsOf: logsURL)
        } catch {
            print(error)
        }
        return ""
    }

    public static var printingMode: LoggerPrintingMode = .onlyMessages {
        didSet {
            switch printingMode {
            case .onlyMessages:
                isOnlyMessagesModeEnable = true
                parametersToPrint = []
            case .print(let parameters):
                isOnlyMessagesModeEnable = false
                parametersToPrint = parameters
            }
        }
    }

    public static var isOn = true

    // MARK: Private properties

    /// Режим, в котором в консоль выводится только сообщение
    private static var isOnlyMessagesModeEnable = true
    private static var parametersToPrint: Set<LoggerPrintElements> = []
    private static var crashlytics = Crashlytics.crashlytics()
    /// Лок для  синхронизации записи в файл
    private static let lock = NSLock()

    /// Место, куда предназначается текст лога
    private enum LogDestination {
        case console, logFile
    }

    // MARK: Public Methods

    public static func log(to type: LogType,
                           message: String,
                           messageDescription: String? = nil,
                           userInfo: [String: String]? = nil,
                           error: Error? = nil,
                           file: String = #fileID,
                           function: String = #function,
                           line: Int  = #line) {
        if !isOn {
            return
        }

        // Дата
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM.dd.yy HH:mm:ss"
        let date = "\n [ДАТА]: " + dateFormatter.string(from: Date())

        // Цвет и тип уведомления
        var emoji = ""
        var messageType = ""

        switch type {
        case .debug:
            emoji = " 🔍 "
            messageType = "[ДЕБАГ]:"
        case .info:
            emoji = " 🌿 "
            messageType = "[ИНФО]:"
        case .notice:
            emoji = " ❕ "
            messageType = "[УВЕДОМЛЕНИЕ]:"
        case .warning:
            emoji = " ⚠️ "
            messageType = "[ПРЕДУПРЕЖДЕНИЕ]:"
        case .error:
            emoji = " ❌ "
            messageType = "[ОШИБКА]:"
        case .critical:
            emoji = " ♠️ "
            messageType = "[КРИТИЧЕСКАЯ ОШИБКА]:"
        }

        let description = " \n [ОПИСАНИЕ]: \(error?.localizedDescription ?? "---")"
        let file = "\n [ФАЙЛ]: \(file)"
        let function = "\n [МЕТОД]: \(function)"
        let line = "\n [СТРОКА]: \(line)"
        let separator = "\n ----------------------------------------------------"

        // Сохранение результатов
        crashlytics.log(messageType + emoji + message)

        if let uid = userInfo?["uid"] {
            AnalyticReporter.setUserID(uid)
            crashlytics.setUserID(uid)
        }

        write(generateString(destination: .logFile,
                             messageType: messageType,
                             emoji: emoji,
                             message: message,
                             description: description,
                             date: date,
                             file: file,
                             function: function,
                             line: line,
                             separator: separator))

        print(generateString(destination: .console,
                             messageType: messageType,
                             emoji: emoji,
                             message: message,
                             description: description,
                             date: date,
                             file: file,
                             function: function,
                             line: line,
                             separator: separator))

        // Ассерт на случай ошибок
        switch type {
        case .error, .critical:
            if let error = error {
                crashlytics.record(error: error)
            }
            // assertionFailure()
        default: break
        }
    }

    public static func cleanCurrentTXT() {
        let text = ""
        do {
            try text.write(to: logsURL, atomically: true, encoding: .utf8)
        } catch {
            print(error)
        }
    }

    // MARK: Private methods
    private static func generateString(destination: LogDestination,
                                       messageType: String,
                                       emoji: String,
                                       message: String,
                                       description: String,
                                       date: String,
                                       file: String,
                                       function: String,
                                       line: String,
                                       separator: String ) -> String {
        switch destination {
        case .console:
            var stringToPrint = isOnlyMessagesModeEnable
            ? messageType + emoji + message
            : " " + messageType + emoji + message + description + date

            if !isOnlyMessagesModeEnable {
                if self.parametersToPrint.contains(.file) {
                    stringToPrint += file
                }

                if self.parametersToPrint.contains(.function) {
                    stringToPrint += function
                }

                if self.parametersToPrint.contains(.line) {
                    stringToPrint += line
                }
                stringToPrint += "\(separator)"
            }

            return stringToPrint

        case .logFile:
            return ("\r\n" + " " + messageType + emoji + message + description + date + file + function + line + separator)
                .replacingOccurrences(of: "\n", with: "\r\n")
        }
    }

    private static func write(_ string: String) {
        lock.lock()
        if let handle = try? FileHandle(forWritingTo: logsURL) {
            handle.seekToEndOfFile()
            handle.write(string.data(using: .utf8)!)
            handle.closeFile()
            lock.unlock()
        } else {
            try? string.data(using: .utf8)?.write(to: logsURL)
            lock.unlock()
        }
    }
}
