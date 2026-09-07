// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation

/// A minimum OS version, as a value.
///
/// For branching on a *value* — a symbol name, a default, a size — from a table that maps entries
/// to the release each one needs. `#available` is a compile-time condition that cannot be stored
/// or passed, so such a table cannot express its own check.
///
/// Calling an API introduced in a later release still requires `#available` at the call site, and
/// the compiler enforces that; this is not a substitute for it.
///
/// Each case pairs a macOS release with the iOS release shipped beside it. Cases are declared
/// oldest first, which is the order `Comparable` and `allCases` follow.
public enum OSVersion: Comparable, Hashable, CaseIterable, Sendable {
    case macOS14
    case macOS15
    case macOS15_1
    case macOS15_2
    case macOS15_4
    case macOS26

    /// Reports this version and every later one as unavailable, so behavior reserved for an older
    /// system can be seen on a current one. Nil answers from the running system.
    ///
    /// Set it before the UI is built: images derived from a version branch are cached by their
    /// callers, and menus are assembled once, so a later change does not reach what is on screen.
    nonisolated(unsafe) public static var simulatedUnavailableFrom: OSVersion?

    /// Whether the running system is this version or later.
    public var isAvailable: Bool {
        if let floor = Self.simulatedUnavailableFrom, self >= floor { return false }

        switch self {
        case .macOS14: if #available(macOS 14.0, iOS 17.0, *) { return true }
        case .macOS15: if #available(macOS 15.0, iOS 18.0, *) { return true }
        case .macOS15_1: if #available(macOS 15.1, iOS 18.1, *) { return true }
        case .macOS15_2: if #available(macOS 15.2, iOS 18.2, *) { return true }
        case .macOS15_4: if #available(macOS 15.4, iOS 18.4, *) { return true }
        case .macOS26: if #available(macOS 26.0, iOS 26.0, *) { return true }
        }

        return false
    }
}
