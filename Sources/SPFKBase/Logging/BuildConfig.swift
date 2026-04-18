// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-utils

import Foundation

/// Represents the possible preprocessor flags
public enum BuildConfig: String, CustomStringConvertible, CaseIterable {
    case debug
    case beta
    case release

    @inline(__always)
    public var description: String {
        switch self {
        case .debug: "DEBUG"
        case .beta: "BETA"
        case .release: ""
        }
    }

    @inline(__always)
    public var isBeta: Bool {
        self != .release
    }

    @inline(__always)
    public var isRelease: Bool {
        self == .release
    }
}
