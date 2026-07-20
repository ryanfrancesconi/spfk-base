// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import CoreFoundation
import Foundation

/// aka UInt32, defined in CFBase.h
extension FourCharCode {
    public static let rhombus = "\u{fffd}"
    public static let unknown = "????"

    /// Create a String representation of a FourCC.
    public var fourCC: String {
        guard self > 0 else { return Self.unknown }

        let out = String(decoding: [
            UInt8(self >> 24),
            UInt8((self >> 16) & 0xFF),
            UInt8((self >> 8) & 0xFF),
            UInt8(self & 0xFF),
        ], as: UTF8.self)

        // "\u{fffd}\u{fffd}\u{fffd}"

        // The replacement character � (often displayed as a black rhombus with a white question mark)
        // is a symbol found in the Unicode standard at code point U+FFFD in the Specials table.
        // It is used to indicate problems when a system is unable to render a stream of data to a correct symbol.
        guard !out.contains(Self.rhombus) else { return Self.unknown }

        return out
    }
}

/// aka SInt32
extension OSStatus {
    /// Create a String representation of a FourCC.
    public var fourCC: String {
        guard self >= 0 else {
            return String(describing: self)
        }

        return FourCharCode(self).fourCC
    }
}

extension String {
    /// Helper function to convert codes for Audio Units
    /// - parameter string: Four character string to convert
    public var fourCC: FourCharCode? {
        guard count == 4 else { return nil }

        var out: FourCharCode = 0

        for char in self.utf8 {
            out <<= 8
            out |= FourCharCode(char)
        }

        return out
    }
}
