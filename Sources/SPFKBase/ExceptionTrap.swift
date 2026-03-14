// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import SPFKBaseC

public enum ExceptionTrap {
    /// n ObjC @try/@catch block exposed via a C function — is the standard and recommended approach for catching
    /// Objective-C exceptions in Swift. Swift has no native @try/@catch mechanism, so a bridging function like this is
    /// necessary.
    public static func withThrowing(_ block: @escaping (() throws -> Void)) throws {
        var swiftError: Error?

        // objc exception
        ExceptionCatcherOperation(
            {
                do {
                    try block()
                } catch {
                    swiftError = error
                }
            },
            { exception in
                Log.error(exception.name.rawValue, exception.reason)

                if Log.buildConfig == .debug {
                    Log.error(exception.callStackSymbols.joined(separator: "\n"))
                }

                swiftError = exception.error
            }
        )

        if let swiftError {
            throw swiftError
        }
    }
}
