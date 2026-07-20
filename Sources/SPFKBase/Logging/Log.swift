// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation
import os.log

/// A simple wrapper on os_log for supporting debug, info errors, and debug signposts.
public enum Log {
    /// Global build config variable.
    /// Set once immediately on app launch. Then app and all packages can read it.
    public nonisolated(unsafe) static var buildConfig: BuildConfig = .debug

    public static let defaultSubsystem: String = Bundle.main.bundleIdentifier ?? "com.spongefork"

    static let defaultLog = OSLog(subsystem: defaultSubsystem, category: "Info")
    static let debugLog = OSLog(subsystem: defaultSubsystem, category: "Debug")
    static let errorLog = OSLog(subsystem: defaultSubsystem, category: "Errors")
    static let poiLog = OSLog(subsystem: defaultSubsystem, category: "PointsOfInterest")

    @inline(__always)
    private static func logFault(_ message: String) {
        os_log("%{public}@", log: errorLog, type: .fault, message)
    }

    @inline(__always)
    private static func logError(_ message: String) {
        os_log("%{public}@", log: errorLog, type: .error, message)
    }

    @inline(__always)
    private static func logInfo(_ message: String) {
        os_log("%{public}@", log: defaultLog, type: .info, message)
    }

    @inline(__always)
    private static func logDebug(_ message: String) {
        os_log("%{public}@", log: debugLog, type: .debug, message)
    }

    @inline(__always)
    private static func assembleMessage(
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        _ items: Any?...,
    ) -> String {
        let fileName = (file as NSString).lastPathComponent

        let content = items.map {
            String(describing: $0 ?? "nil")
        }.joined(separator: " ")

        let message = "\(fileName):\(function):\(line):\(content)"

        return message
    }

    // MARK: - Public

    @inline(__always)
    public static func `default`(
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        _ items: Any?...,
    ) {
        autoreleasepool {
            let message = assembleMessage(file: file, function: function, line: line, items)
            logInfo(message)
        }
    }

    @inline(__always)
    public static func debug(
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        _ items: Any?...,
    ) {
        guard buildConfig != .release else { return }

        autoreleasepool {
            let message = assembleMessage(file: file, function: function, line: line, items)
            logDebug(message)
        }
    }

    @inline(__always)
    public static func error(
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        _ items: Any?...,
    ) {
        autoreleasepool {
            let message = "🚩 " + assembleMessage(file: file, function: function, line: line, items)

            logError(message)
        }
    }

    @inline(__always)
    public static func fault(
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        _ items: Any?...,
    ) {
        autoreleasepool {
            let message = "⛔️ " + assembleMessage(file: file, function: function, line: line, items)
            logFault(message)
        }
    }

    public static func printCallStack() {
        var lines: [String] = ["\n"]

        for callStackSymbol in Thread.callStackSymbols {
            lines.append(callStackSymbol)
        }

        Log.error(
            lines.joined(separator: "\n"),
        )
    }
}

extension Log {
    @inline(__always)
    public static func signpost(
        _ type: OSSignpostType,
        name: StaticString
    ) {
        guard buildConfig == .debug else { return }

        os_signpost(type, log: poiLog, name: name)
    }
}
