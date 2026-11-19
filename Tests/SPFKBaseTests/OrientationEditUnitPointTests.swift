// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SPFKBase
import Testing

struct OrientationEditUnitPointTests {
    private let points: [SIMD2<Double>] = [SIMD2(0, 0), SIMD2(1, 0), SIMD2(0.2, 0.7), SIMD2(0.9, 0.35)]

    private func isClose(_ a: SIMD2<Double>, _ b: SIMD2<Double>) -> Bool {
        abs(a.x - b.x) < 1e-12 && abs(a.y - b.y) < 1e-12
    }

    @Test(arguments: OrientationEdit.allCases)
    func theMappingRoundTrips(orientation: OrientationEdit) {
        for point in points {
            let shown = orientation.shownUnitPoint(forDisplayed: point)
            #expect(isClose(orientation.displayedUnitPoint(forShown: shown), point), "\(orientation) \(point)")
        }
    }

    @Test func aRightTurnTakesTheTopLeftToTheTopRight() {
        #expect(OrientationEdit.right.shownUnitPoint(forDisplayed: SIMD2(0, 0)) == SIMD2(1, 0))
        #expect(OrientationEdit.upMirrored.shownUnitPoint(forDisplayed: SIMD2(0, 0)) == SIMD2(1, 0))
        #expect(OrientationEdit.down.shownUnitPoint(forDisplayed: SIMD2(0, 0)) == SIMD2(1, 1))
        #expect(OrientationEdit.left.shownUnitPoint(forDisplayed: SIMD2(0, 0)) == SIMD2(0, 1))
    }

    /// Mapping through two edits one after the other is mapping through their composition, so the
    /// mapping agrees with ``OrientationEdit/composed(after:)`` for every pair.
    @Test(arguments: OrientationEdit.allCases)
    func mappingThroughTwoEditsIsMappingThroughTheirComposition(first: OrientationEdit) {
        for second in OrientationEdit.allCases {
            let composed = second.composed(after: first)

            for point in points {
                let stepwise = second.shownUnitPoint(forDisplayed: first.shownUnitPoint(forDisplayed: point))
                #expect(isClose(stepwise, composed.shownUnitPoint(forDisplayed: point)), "\(second) after \(first)")
            }
        }
    }
}
