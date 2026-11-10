// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SPFKBase
import Testing

/// The group laws of the composition. Pixel checks against ImageIO live in `SPFKImageTests`.
struct OrientationEditTests {
    @Test(arguments: OrientationEdit.allCases)
    func fourRotationsReturnToTheStart(start: OrientationEdit) {
        #expect(start.rotatedRight.rotatedRight.rotatedRight.rotatedRight == start)
        #expect(start.rotatedLeft.rotatedLeft.rotatedLeft.rotatedLeft == start)
        #expect(start.rotatedLeft.rotatedRight == start)
    }

    @Test(arguments: OrientationEdit.allCases)
    func twoFlipsReturnToTheStart(start: OrientationEdit) {
        #expect(start.flippedHorizontally.flippedHorizontally == start)
        #expect(start.flippedVertically.flippedVertically == start)
    }

    @Test func rotateRightThenFlipHorizontalEqualsFlipVerticalThenRotateRight() {
        #expect(OrientationEdit.up.rotatedRight.flippedHorizontally == OrientationEdit.up.flippedVertically.rotatedRight)
    }

    @Test(arguments: OrientationEdit.allCases, OrientationEdit.allCases)
    func compositionIsAssociativeWithAThird(a: OrientationEdit, b: OrientationEdit) {
        for c in OrientationEdit.allCases {
            #expect(a.composed(after: b).composed(after: c) == a.composed(after: b.composed(after: c)))
        }
    }

    @Test(arguments: OrientationEdit.allCases)
    func upIsTheIdentityOnBothSides(edit: OrientationEdit) {
        #expect(edit.composed(after: .up) == edit)
        #expect(OrientationEdit.up.composed(after: edit) == edit)
    }

    @Test(arguments: OrientationEdit.allCases)
    func turnsAndMirrorRoundTrip(edit: OrientationEdit) {
        #expect(OrientationEdit(quarterTurns: edit.quarterTurns, isMirrored: edit.isMirrored) == edit)
        #expect(OrientationEdit(quarterTurns: edit.quarterTurns + 8, isMirrored: edit.isMirrored) == edit)
        #expect(OrientationEdit(quarterTurns: edit.quarterTurns - 4, isMirrored: edit.isMirrored) == edit)
    }

    @Test(arguments: [0, 9, -1])
    func anOutOfRangeFileTagReadsAsUp(tag: Int) {
        #expect(OrientationEdit.right.applied(toFileOrientation: tag) == OrientationEdit.right.rawValue)
    }
}
