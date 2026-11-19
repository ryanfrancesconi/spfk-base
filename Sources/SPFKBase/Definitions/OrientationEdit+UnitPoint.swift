// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation

extension OrientationEdit {
    /// A point in fractions of the displayed picture, y down, before this edit, as fractions of the
    /// picture as shown after it.
    public func shownUnitPoint(forDisplayed point: SIMD2<Double>) -> SIMD2<Double> {
        var p = point

        if isMirrored {
            p.x = 1 - p.x
        }

        for _ in 0 ..< quarterTurns {
            p = SIMD2(1 - p.y, p.x)
        }

        return p
    }

    /// The inverse of ``shownUnitPoint(forDisplayed:)``.
    public func displayedUnitPoint(forShown point: SIMD2<Double>) -> SIMD2<Double> {
        var p = point

        for _ in 0 ..< quarterTurns {
            p = SIMD2(p.y, 1 - p.x)
        }

        if isMirrored {
            p.x = 1 - p.x
        }

        return p
    }
}
