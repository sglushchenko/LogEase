//
//  File.swift
//  
//
//  Created by Serhii Hlushchenko on 01.08.2024.
//

import Foundation

public class ConsoleDestination: BaseDestination {
    public enum LoggerType {
            case nslog
            case print
        }
    
    public var loggerType: LoggerType = .print
    
    public override func send(_ level: LogEase.Level, msg: String, file: StaticString, function: StaticString, line: Int) -> String? {
        
        let formattedString = super.send(level, msg: msg, file: file, function: function, line: line)

        if let message = formattedString {
#if os(Linux)
            print(message)
#else
            switch loggerType {
            case .nslog:
                NSLog("%@", message)
            case .print:
                print(message)
            }
#endif
        }
        return formattedString
    }
    
}
