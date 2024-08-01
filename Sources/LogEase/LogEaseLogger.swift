// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public class LogEaseLogger {
    public enum Level: Int {
        case verbose = 0
        case debug
        case info
        case warning
        case error
        
        var string: String {
            switch self {
            case .verbose:
                return "VERBOSE"
            case .debug:
                return "DEBUG"
            case .info:
                return "INFO"
            case .warning:
                return "WARNING"
            case .error:
                return "ERROR"
            }
        }
    }
    
    public init(destinations: Set<BaseDestination> = Set<BaseDestination>(), queue: DispatchQueue = DispatchQueue(label: "logease.queue", attributes: .concurrent)) {
        self.queue = queue
        self.destinations = destinations
    }
    
    // a set of active destinations
    public private(set) var destinations = Set<BaseDestination>()
    
    private let queue: DispatchQueue
    
    public func addDestination(_ destination: BaseDestination) {
        return queue.sync(flags: DispatchWorkItemFlags.barrier) {
            guard !destinations.contains(destination) else { return }
            destinations.insert(destination)
        }
    }
    
    public func removeDestination(_ destination: BaseDestination) {
        return queue.sync(flags: DispatchWorkItemFlags.barrier) {
            guard destinations.contains(destination) else { return }
            destinations.remove(destination)
        }
    }
    
    public func removeAllDestinations() {
        queue.sync(flags: DispatchWorkItemFlags.barrier) {
            destinations.removeAll()
        }
    }
    
    /// log something generally unimportant (lowest priority)
    public func verbose(_ message: @autoclosure () -> Any,
                        file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        custom(level: .verbose, message: message(), file: file, function: function, line: line)
    }

    /// log something which help during debugging (low priority)
    public func debug(_ message: @autoclosure () -> Any,
                      file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        custom(level: .debug, message: message(), file: file, function: function, line: line)
    }

    /// log something which you are really interested but which is not an issue or error (normal priority)
    public func info(_ message: @autoclosure () -> Any,
                     file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        custom(level: .info, message: message(), file: file, function: function, line: line)
    }

    /// log something which may cause big trouble soon (high priority)
    public func warning(_ message: @autoclosure () -> Any,
                        file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        custom(level: .warning, message: message(), file: file, function: function, line: line)
    }

    /// log something which will keep you awake at night (highest priority)
    public func error(_ message: @autoclosure () -> Any,
                      file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        custom(level: .error, message: message(), file: file, function: function, line: line)
    }

    /// custom logging to manually adjust values, should just be used by other frameworks
    public func custom(level: Level, message: @autoclosure () -> Any,
                       file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        let destinations = queue.sync { self.destinations }
        for dest in destinations {
            if dest.shouldLevelBeLogged(level) {
                let msgStr = "\(message())"
                if dest.asynchronously {
                    queue.async {
                        _ = dest.send(level, msg: msgStr, file: file, function: function, line: line)
                    }
                } else {
                    queue.sync {
                        _ = dest.send(level, msg: msgStr, file: file, function: function, line: line)
                    }
                }
            }
        }
    }
}
