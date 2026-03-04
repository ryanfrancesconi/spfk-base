// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-utils

import Foundation

extension BinaryFloatingPoint {
    public func round(
        _ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero,
        divisor: any BinaryFloatingPoint
    ) -> Self {
        let divisor = Self(divisor)

        guard divisor > 0 else { return self }

        return divisor * (self / divisor).rounded(rule)
    }
}

extension Array where Element: FloatingPoint {
    public func mean() -> Element {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / Element(count)
    }
}

extension BinaryFloatingPoint {
    public static var unitIntervalRange: ClosedRange<Self> { 0 ... 1 }
}
