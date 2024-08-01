//
//  File.swift
//  
//
//  Created by Serhii Hlushchenko on 01.08.2024.
//

import Foundation

// store operating system / platform
//#if os(iOS)
//let OS = "iOS"
//#elseif os(OSX)
//let OS = "OSX"
//#elseif os(watchOS)
//let OS = "watchOS"
//#elseif os(tvOS)
//let OS = "tvOS"
//#elseif os(Linux)
//let OS = "Linux"
//#elseif os(FreeBSD)
//let OS = "FreeBSD"
//#elseif os(Windows)
//let OS = "Windows"
//#elseif os(Android)
//let OS = "Android"
//#else
//let OS = "Unknown"
//#endif

/// destination which all others inherit from. do not directly use
public class BaseDestination: Equatable, Hashable {
    static public func == (lhs: BaseDestination, rhs: BaseDestination) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    /// output format pattern, see documentation for syntax
    public var format = "$DHH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M"

    /// runs in own serial background thread for better performance
    public var asynchronously = true

    /// do not log any message which has a lower level than this one
    public var outputLevel = LogEase.Level.verbose

    private let formatter = DateFormatter()
    private let startDate = Date()

    private let identifier: String

    private var queue: DispatchQueue

    var reset = ""
    var escape = ""
    
    public init(identifier: String = UUID().uuidString, queue: DispatchQueue = DispatchQueue(label: "com.logease.destination")) {
        self.identifier = identifier
        self.queue = queue
    }

    public func send(_ level: LogEase.Level, msg: String, file: StaticString,
                   function: StaticString, line: Int) -> String? {
        return formatMessage(level: level, msg: msg,
                                 file: file, function: function, line: line)
    }

//    public func execute(synchronously: Bool, block: @escaping () -> Void) {
//        guard let queue = queue else {
//            fatalError("Queue not set")
//        }
//        if synchronously {
//            queue.sync(execute: block)
//        } else {
//            queue.async(execute: block)
//        }
//    }
//
//    public func executeSynchronously<T>(block: @escaping () throws -> T) rethrows -> T {
//        guard let queue = queue else {
//            fatalError("Queue not set")
//        }
//        return try queue.sync(execute: block)
//    }

    ////////////////////////////////
    // MARK: Format
    ////////////////////////////////

    /// returns (padding length value, offset in string after padding info)
//    private func parsePadding(_ text: String) -> (Int, Int) {
//        // look for digits followed by a alpha character
//        var s: String!
//        var sign: Int = 1
//        if text.firstChar == "-" {
//            sign = -1
//            s = String(text.suffix(from: text.index(text.startIndex, offsetBy: 1)))
//        } else {
//            s = text
//        }
//        let numStr = String(s.prefix { $0 >= "0" && $0 <= "9" })
//        if let num = Int(numStr) {
//            return (sign * num, (sign == -1 ? 1 : 0) + numStr.count)
//        } else {
//            return (0, 0)
//        }
//    }
//
//    private func paddedString(_ text: String, _ toLength: Int, truncating: Bool = false) -> String {
//        if toLength > 0 {
//            // Pad to the left of the string
//            if text.count > toLength {
//                // Hm... better to use suffix or prefix?
//                return truncating ? String(text.suffix(toLength)) : text
//            } else {
//                return "".padding(toLength: toLength - text.count, withPad: " ", startingAt: 0) + text
//            }
//        } else if toLength < 0 {
//            // Pad to the right of the string
//            let maxLength = truncating ? -toLength : max(-toLength, text.count)
//            return text.padding(toLength: maxLength, withPad: " ", startingAt: 0)
//        } else {
//            return text
//        }
//    }
    
    public var showDate: Bool = true
    public var showLevel: Bool = true
    public var showFileName: Bool = true
    public var showFunctionName: Bool = true
    public var showLineNumber: Bool = true

    /// returns the log message based on the format pattern
    func formatMessage(level: LogEase.Level, msg: String,
                       file: StaticString, function: StaticString, line: Int) -> String {
        
        var extendedDetails: String = ""
        
        if showDate {
            extendedDetails += "\(self.formatter.string(from: Date())) "
        }
        
        if showLevel {
            extendedDetails += "[\(level.string)] "
        }
        
        if showFileName {
            extendedDetails += "[\(file)\((showLineNumber ? ":" + String(line) : ""))] "
        } else if showLineNumber {
            extendedDetails += "[\(line)] "
        }
        
        if showFunctionName {
            extendedDetails += "\(stripParams(function: function)) "
        }
        
        return "\(extendedDetails)> \(msg)"
    }

    /// returns the log payload as optional JSON string
//    func messageToJSON(_ level: SwiftyBeaver.Level, msg: String,
//        thread: String, file: String, function: String, line: Int, context: Any? = nil) -> String? {
//        var dict: [String: Any] = [
//            "timestamp": Date().timeIntervalSince1970,
//            "level": level.rawValue,
//            "message": msg,
//            "thread": thread,
//            "file": file,
//            "function": function,
//            "line": line
//            ]
//        if let cx = context {
//            dict["context"] = cx
//        }
//        return jsonStringFromDict(dict)
//    }

    /// returns the string of a level
//    func levelWord(_ level: SwiftyBeaver.Level) -> String {
//
//        var str = ""
//
//        switch level {
//        case .verbose:
//            str = levelString.verbose
//            
//        case .debug:
//            str = levelString.debug
//
//        case .info:
//            str = levelString.info
//
//        case .warning:
//            str = levelString.warning
//
//        case .error:
//            str = levelString.error
//
//        case .critical:
//            str = levelString.critical
//
//        case .fault:
//            str = levelString.fault
//        }
//        return str
//    }

    /// returns color string for level
//    func colorForLevel(_ level: SwiftyBeaver.Level) -> String {
//        var color = ""
//
//        switch level {
//        case .verbose:
//            color = levelColor.verbose
//            
//        case .debug:
//            color = levelColor.debug
//
//        case .info:
//            color = levelColor.info
//
//        case .warning:
//            color = levelColor.warning
//
//        case .error:
//            color = levelColor.error
//
//        case .critical:
//            color = levelColor.critical
//            
//        case .fault:
//            color = levelColor.fault
//        }
//        return color
//    }

    /// returns the filename of a path
    func fileNameOfFile(_ file: String) -> String {
        let fileParts = file.components(separatedBy: "/")
        if let lastPart = fileParts.last {
            return lastPart
        }
        return ""
    }

    /// returns the filename without suffix (= file ending) of a path
    func fileNameWithoutSuffix(_ file: String) -> String {
        let fileName = fileNameOfFile(file)

        if !fileName.isEmpty {
            let fileNameParts = fileName.components(separatedBy: ".")
            if let firstPart = fileNameParts.first {
                return firstPart
            }
        }
        return ""
    }

    /// returns a formatted date string
    /// optionally in a given abbreviated timezone like "UTC"
//    func formatDate(_ dateFormat: String, timeZone: String = "") -> String {
//        if !timeZone.isEmpty {
//            formatter.timeZone = TimeZone(abbreviation: timeZone)
//        }
//        formatter.calendar = calendar
//        formatter.dateFormat = dateFormat
//        //let dateStr = formatter.string(from: NSDate() as Date)
//        let dateStr = formatter.string(from: Date())
//        return dateStr
//    }

    /// returns a uptime string
//    func uptime() -> String {
//        let interval = Date().timeIntervalSince(startDate)
//
//        let hours = Int(interval) / 3600
//        let minutes = Int(interval / 60) - Int(hours * 60)
//        let seconds = Int(interval) - (Int(interval / 60) * 60)
//        let milliseconds = Int(interval.truncatingRemainder(dividingBy: 1) * 1000)
//
//        return String(format: "%0.2d:%0.2d:%0.2d.%03d", arguments: [hours, minutes, seconds, milliseconds])
//    }

    /// returns the json-encoded string value
    /// after it was encoded by jsonStringFromDict
//    func jsonStringValue(_ jsonString: String?, key: String) -> String {
//        guard let str = jsonString else {
//            return ""
//        }
//
//        // remove the leading {"key":" from the json string and the final }
//        let offset = key.length + 5
//        let endIndex = str.index(str.startIndex,
//                                 offsetBy: str.length - 2)
//        let range = str.index(str.startIndex, offsetBy: offset)..<endIndex
//        #if swift(>=3.2)
//        return String(str[range])
//        #else
//        return str[range]
//        #endif
//    }

    /// turns dict into JSON-encoded string
//    func jsonStringFromDict(_ dict: [String: Any]) -> String? {
//        var jsonString: String?
//
//        // try to create JSON string
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
//            jsonString = String(data: jsonData, encoding: .utf8)
//        } catch {
//            print("SwiftyBeaver could not create JSON from dict.")
//        }
//        return jsonString
//    }

    public func shouldLevelBeLogged(_ level: LogEase.Level) -> Bool {
        if level.rawValue >= outputLevel.rawValue {
            return true
        } else {
            return false
        }
    }
    
    /// removes the parameters from a function because it looks weird with a single param
    private func stripParams(function: StaticString) -> String {
        var f = "\(function)"
        if let indexOfBrace = f.firstIndex(of: "(") {
            f = String(f[..<indexOfBrace])
        }
        f += "()"
        return f
    }
}
