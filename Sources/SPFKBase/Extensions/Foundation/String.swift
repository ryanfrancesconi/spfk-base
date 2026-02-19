// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-utils

import AudioToolbox
import SwiftExtensions

extension String {
    public static let nbsp: String = "\u{00A0}"
}

extension String {
    /// Retains only ASCII alphanumerics, `+`, `-`, and `_`
    @_disfavoredOverload
    public func onlyASCIIAlphanumericsPlusMinusUnderscore() -> String {
        let okayChars = "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-_"
        return only(charactersIn: okayChars)
    }

    /// Translate U+00A0 NO-BREAK SPACE to standard " "
    @_disfavoredOverload
    public func normalizedWhitespaces() -> String {
        removing(characters: Self.nbsp)
    }

    @_disfavoredOverload
    public var abbreviated: String {
        let input = onlyASCIIAlphanumericsPlusMinusUnderscore()
        let uppercaseLetters = input.only(.uppercaseLetters).prefix(4).string

        var output = ""

        if uppercaseLetters.count > 1 {
            output = uppercaseLetters

        } else if input.contains(" ") {
            let parts = input.components(separatedBy: " ")

            for i in 0 ..< parts.count {
                guard let letter = parts[i].first?.string else { continue }
                output += letter
            }

        } else if input.count > 1 {
            output = input.prefix(2).string
        }

        return output.uppercased()
    }
}

// MARK: - Character Filters

extension String {
    /// theCamel = The Camel
    @_disfavoredOverload
    public var spacedTitleCased: String {
        replacingOccurrences(
            of: "([A-Z])",
            with: " $1",
            options: .regularExpression,
            range: range(of: self)
        )
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .capitalized // If input is in camelCase
    }
}

// MARK: - Comparison

extension String {
    @_disfavoredOverload
    public func equalsIgnoringCase(_ string: String) -> Bool {
        caseInsensitiveCompare(string) == .orderedSame
    }

    @_disfavoredOverload
    public func standardCompare(with otherString: String, ascending: Bool = true) -> Bool {
        let comparisonResult = localizedStandardCompare(otherString)

        return ascending ?
            comparisonResult == .orderedAscending :
            comparisonResult == .orderedDescending
    }
}

// MARK: - Delimited Strings

extension StringProtocol {
    /// Splits a delimited string into elements.
    ///
    /// - Optionally, you can allow duplicates or allow empty elements.
    /// - Omits elements starting with a null character.
    @_disfavoredOverload
    public func splitDelimited(
        delimiter: String = ",",
        allowDuplicates: Bool = false
    ) -> [String] {
        var array = components(separatedBy: delimiter).map(\.trimmed)

        array = array.filter(\.isNotEmpty)

        return allowDuplicates ? array : array.localizedCaseInsensitiveRemovingDuplicates()
    }
}

extension StringProtocol {
    /// Convenience conversion
    @_disfavoredOverload
    public var auValue: AUValue? {
        AUValue(self)
    }

    // useful for xml parsing
    @_disfavoredOverload
    public var boolValue: Bool {
        lowercased() == "true" || self == "1"
    }
}

extension String {
    @_disfavoredOverload
    public var urlEncoded: String? {
        addingPercentEncoding(withAllowedCharacters: .urlAllowed)
    }

    @_disfavoredOverload
    public var urlQueryEncoded: String? {
        urlEncoded?.replacingOccurrences(of: "%20", with: "+")
    }
}

extension CharacterSet {
    /// as per RFC 3986
    public static let urlAllowed: CharacterSet = .alphanumerics.union(
        .init(charactersIn: "-._~")
    )
}
