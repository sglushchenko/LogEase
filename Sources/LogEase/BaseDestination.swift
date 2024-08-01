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
    public var outputLevel = LogEaseLogger.Level.verbose

    public var showDate: Bool = true
    public var showLevel: Bool = true
    public var showFileName: Bool = true
    public var showFunctionName: Bool = true
    public var showLineNumber: Bool = true
    
    private let formatter = DateFormatter()
    private let startDate = Date()

    private let identifier: String

    private var queue: DispatchQueue
    
    public init(identifier: String = UUID().uuidString, queue: DispatchQueue = DispatchQueue(label: "com.logease.destination")) {
        self.identifier = identifier
        self.queue = queue
    }

    public func send(_ level: LogEaseLogger.Level, msg: String, file: StaticString,
                   function: StaticString, line: Int) -> String? {
        return formatMessage(level: level, msg: msg,
                                 file: file, function: function, line: line)
    }

    /// returns the log message based on the format pattern
    func formatMessage(level: LogEaseLogger.Level, msg: String,
                       file: StaticString, function: StaticString, line: Int) -> String {
        
        var extendedDetails: String = ""
        
        if showDate {
            extendedDetails += "\(self.formatter.string(from: Date())) "
        }
        
        if showLevel {
            extendedDetails += "[\(level.string)] "
        }
        
        if showFileName {
            let fileName = "\(file)".split(separator: "/").last ?? ""
            extendedDetails += "[\(fileName)\((showLineNumber ? ":" + String(line) : ""))] "
        } else if showLineNumber {
            extendedDetails += "[\(line)] "
        }
        
        if showFunctionName {
            extendedDetails += "\(stripParams(function: function)) "
        }
        
        return "\(extendedDetails)> \(msg)"
    }

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

    public func shouldLevelBeLogged(_ level: LogEaseLogger.Level) -> Bool {
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
