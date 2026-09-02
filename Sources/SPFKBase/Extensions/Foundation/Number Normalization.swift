// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation

// MARK: - Normalization Helpers - taken from AudioKit

/// Scaling factors for mapping a control's value onto a power-law curve, useful for UI controls.
extension Double {
    /// Return a value on [minimum, maximum] to a [0, 1] range, according to a taper.
    ///
    /// - Parameters:
    ///   - range: Source range. Must not be empty.
    ///   - taper: Must be a positive number, taper = 1 is linear.
    public func normalized(
        from range: ClosedRange<Double>,
        taper: Double = 1
    ) -> Double {
        assert(taper > 0, "Cannot have non-positive taper.")
        return pow((self - range.lowerBound) / (range.upperBound - range.lowerBound), 1.0 / taper)
    }

    /// Return a value on [0, 1] to a [minimum, maximum] range, according to a taper.
    ///
    /// - Parameters:
    ///   - range: Target range.
    ///   - taper: Must be a positive number, taper = 1 is linear.
    public func denormalized(
        to range: ClosedRange<Double>,
        taper: Double = 1
    ) -> Double {
        assert(taper > 0, "Cannot have non-positive taper.")
        return range.lowerBound + (range.upperBound - range.lowerBound) * pow(self, taper)
    }
}

/// `AUValue` is a typealias for `Float`, so these serve Audio Unit parameter values too.
extension Float {
    /// Return a value on [minimum, maximum] to a [0, 1] range, according to a taper.
    ///
    /// - Parameters:
    ///   - range: Source range. Must not be empty.
    ///   - taper: Must be a positive number, taper = 1 is linear.
    public func normalized(
        from range: ClosedRange<Float>,
        taper: Float = 1
    ) -> Float {
        assert(taper > 0, "Cannot have non-positive taper.")
        return powf((self - range.lowerBound) / (range.upperBound - range.lowerBound), 1.0 / taper)
    }

    /// Return a value on [0, 1] to a [minimum, maximum] range, according to a taper.
    ///
    /// - Parameters:
    ///   - range: Target range.
    ///   - taper: Must be a positive number, taper = 1 is linear.
    public func denormalized(
        to range: ClosedRange<Float>,
        taper: Float = 1
    ) -> Float {
        assert(taper > 0, "Cannot have non-positive taper.")
        return range.lowerBound + (range.upperBound - range.lowerBound) * powf(self, taper)
    }
}
