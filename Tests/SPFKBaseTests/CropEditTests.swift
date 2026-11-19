// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SPFKBase
import Testing

struct CropEditTests {
    private let ratios = CropAspect.allCases.compactMap(\.landscapeRatio)

    private func isInside(_ crop: CropEdit, _ width: Int, _ height: Int, tolerance: Double = 1e-6) -> Bool {
        crop.corners(imageWidth: width, imageHeight: height).allSatisfy { corner in
            corner.x >= -tolerance && corner.y >= -tolerance
                && corner.x <= Double(width) + tolerance && corner.y <= Double(height) + tolerance
        }
    }

    /// Unturned, the largest centered rectangle touches two opposite sides and fits between the others.
    @Test(arguments: [(3000, 2000), (2000, 3000)])
    func largestCenteredAtZeroDegreesFillsTheLimitingSide(width: Int, height: Int) {
        for ratio in ratios + ratios.map({ 1 / $0 }) {
            let crop = CropEdit.largestCentered(aspect: ratio, imageWidth: width, imageHeight: height)
            let keptWidth = crop.width * Double(width)
            let keptHeight = crop.height * Double(height)

            #expect(abs(keptWidth / keptHeight - ratio) < 1e-9)
            #expect(crop.width == 1 || crop.height == 1)
            #expect(crop.width <= 1 && crop.height <= 1)
            #expect(crop.centerX == 0 && crop.centerY == 0)
        }
    }

    @Test(arguments: [5.0, 20.0, -20.0])
    func largestCenteredUnderAnAngleIsInsideAndCannotGrow(degrees: Double) {
        for (width, height) in [(3000, 2000), (2000, 3000)] {
            for ratio in ratios + ratios.map({ 1 / $0 }) {
                let crop = CropEdit.largestCentered(aspect: ratio, imageWidth: width, imageHeight: height, straighten: degrees)
                #expect(isInside(crop, width, height), "\(ratio) at \(degrees)°")

                var grown = crop
                grown.width *= 1.01
                grown.height *= 1.01
                #expect(!isInside(grown, width, height), "\(ratio) at \(degrees)° grown")
            }
        }
    }

    @Test func containedLeavesAnInsideCropAlone() {
        let crop = CropEdit(centerX: 0.1, centerY: -0.1, width: 0.5, height: 0.5, straighten: 3, aspect: .square)
        #expect(crop.contained(imageWidth: 3000, imageHeight: 2000) == crop)
    }

    @Test func containedBringsAnOutsideCropInsideAboutItsOwnCenter() {
        let crop = CropEdit(centerX: 0.3, centerY: 0.2, width: 0.8, height: 0.9, straighten: 10, aspect: .ratio4x3)
        let result = crop.contained(imageWidth: 3000, imageHeight: 2000)

        #expect(!isInside(crop, 3000, 2000))
        #expect(isInside(result, 3000, 2000))
        #expect(result.centerX == crop.centerX && result.centerY == crop.centerY)
        #expect(result.straighten == crop.straighten && result.aspect == crop.aspect)
        #expect(abs(result.width / result.height - crop.width / crop.height) < 1e-9)
    }

    @Test func croppingFollowsThePhotosShape() {
        let landscape = CropEdit.cropping(to: .ratio16x9, displayedWidth: 4000, displayedHeight: 3000)
        let portrait = CropEdit.cropping(to: .ratio16x9, displayedWidth: 3000, displayedHeight: 4000)

        #expect(abs(landscape.width * 4000 / (landscape.height * 3000) - 16.0 / 9) < 1e-9)
        #expect(abs(portrait.width * 3000 / (portrait.height * 4000) - 9.0 / 16) < 1e-9)
        #expect(landscape.aspect == .ratio16x9)
    }

    /// A landscape picture with a pending quarter turn is shown in portrait, so it gets 9:16 as shown,
    /// which is 16:9 in its stored frame turned: the same as a portrait picture gets.
    @Test(arguments: [OrientationEdit.right, .left, .rightMirrored])
    func croppingAPendingQuarterTurnFollowsTheShapeAsShown(orientation: OrientationEdit) {
        let turned = CropEdit.cropping(to: .ratio4x5, displayedWidth: 4000, displayedHeight: 3000, pendingOrientation: orientation)
        let shown = turned.pixelSize(imageWidth: 4000, imageHeight: 3000)
        let portrait = CropEdit.cropping(to: .ratio4x5, displayedWidth: 3000, displayedHeight: 4000)
            .pixelSize(imageWidth: 3000, imageHeight: 4000)

        // Shown after the turn, the stored width is the height on screen.
        #expect(shown.height == portrait.width)
        #expect(shown.width == portrait.height)
    }

    @Test func croppingKeepsTheAngleInside() {
        let crop = CropEdit.cropping(to: .square, displayedWidth: 3000, displayedHeight: 2000, straighten: 7)
        #expect(crop.straighten == 7)
        #expect(isInside(crop, 3000, 2000))
    }

    @Test func nonFiniteAndOutOfRangeValuesSanitize() {
        let crop = CropEdit(centerX: .nan, centerY: 2, width: .infinity, height: 0, straighten: -90)

        #expect(crop.centerX == 0)
        #expect(crop.centerY == 0.5)
        #expect(crop.width == 1)
        #expect(crop.height == CropEdit.sizeRange.lowerBound)
        #expect(crop.straighten == -45)
    }

    @Test func identityIsGeometricOnly() {
        #expect(CropEdit(aspect: .square).isIdentity)
        #expect(!CropEdit(straighten: 1).isIdentity)
        #expect(!CropEdit(width: 0.5).isIdentity)
    }

    @Test func pixelSizeRoundsToWholePixelsAndNeverZero() {
        let size = CropEdit(width: 0.3333, height: 0.01).pixelSize(imageWidth: 1000, imageHeight: 20)
        #expect(size.width == 333)
        #expect(size.height == 1)
    }

    @Test func codableRoundTrip() throws {
        let crop = CropEdit(centerX: 0.1, centerY: -0.2, width: 0.6, height: 0.4, straighten: -3.5, aspect: .ratio5x7)
        let decoded = try JSONDecoder().decode(CropEdit.self, from: JSONEncoder().encode(crop))
        #expect(decoded == crop)
    }

    // MARK: - Custom

    @Test func customSidesSanitizeAndAreNotGeometry() throws {
        let crop = CropEdit(aspect: .custom, customWidth: -3, customHeight: 50000)
        #expect(crop.customWidth == 0)
        #expect(crop.customHeight == CropEdit.customRange.upperBound)
        #expect(crop.customRatio == nil)
        #expect(crop.isIdentity)
        #expect(CropEdit(customWidth: .nan).customWidth == 0)

        let set = CropEdit(aspect: .custom, customWidth: 2, customHeight: 1)
        #expect(set.customRatio == 2)
        #expect(set.isIdentity)

        let decoded = try JSONDecoder().decode(CropEdit.self, from: JSONEncoder().encode(set))
        #expect(decoded == set)
    }

    @Test func dataWrittenBeforeTheCustomSidesDecodesThemAsUnset() throws {
        let json = #"{"centerX":0.1,"centerY":-0.2,"width":0.6,"height":0.4,"straighten":-3.5,"aspect":"ratio5x7"}"#
        let crop = try JSONDecoder().decode(CropEdit.self, from: Data(json.utf8))

        #expect(crop == CropEdit(centerX: 0.1, centerY: -0.2, width: 0.6, height: 0.4, straighten: -3.5, aspect: .ratio5x7))
        #expect(crop.customWidth == 0 && crop.customHeight == 0)
    }

    @Test func croppingToCustomKeepsThePicturesShape() {
        let crop = CropEdit.cropping(to: .custom, displayedWidth: 3000, displayedHeight: 2000)
        #expect(crop.width == 1 && crop.height == 1)
        #expect(crop.aspect == .custom)
    }

    // MARK: - Straighten

    private func isClose(_ a: CropEdit, _ b: CropEdit) -> Bool {
        abs(a.centerX - b.centerX) < 1e-12 && abs(a.centerY - b.centerY) < 1e-12
            && abs(a.width - b.width) < 1e-12 && abs(a.height - b.height) < 1e-12 && a.straighten == b.straighten
    }

    @Test(arguments: OrientationEdit.allCases)
    func straighteningAwayAndBackRestoresTheCrop(orientation: OrientationEdit) {
        let base = CropEdit(centerX: 0.08, centerY: -0.05, width: 0.7, height: 0.65, straighten: 2)
            .contained(imageWidth: 3000, imageHeight: 2000)
        let shownBase = orientation.isMirrored ? -base.straighten : base.straighten

        for angle in [10.0, -25, 45] {
            let turned = base.straightened(to: angle, orientation: orientation, imageWidth: 3000, imageHeight: 2000)
            #expect(turned.straighten == (orientation.isMirrored ? -angle : angle))
            #expect(isInside(turned, 3000, 2000), "\(orientation) \(angle)°")
        }

        let back = base.straightened(to: shownBase, orientation: orientation, imageWidth: 3000, imageHeight: 2000)
        #expect(back == base)
    }

    /// Turned 45° in a corner, a small crop has almost no room about its own center; it moves toward
    /// the picture's center rather than shrinking to nothing. Nearer the middle it stays put.
    @Test func aCornerCropMovesInRatherThanVanishing() {
        let nearby = CropEdit(centerX: -0.42, centerY: -0.42, width: 0.15, height: 0.15)
        let kept = nearby.straightened(to: 45, orientation: .up, imageWidth: 3000, imageHeight: 2000)
        #expect(kept.centerX == nearby.centerX && kept.centerY == nearby.centerY)

        let base = CropEdit(centerX: -0.49, centerY: -0.49, width: 0.15, height: 0.15)
        let turned = base.straightened(to: 45, orientation: .up, imageWidth: 3000, imageHeight: 2000)

        #expect(isInside(turned, 3000, 2000))
        #expect(turned.width >= base.width / 2 - 1e-9 && turned.height >= base.height / 2 - 1e-9)
        #expect(abs(turned.centerX) < abs(base.centerX) && abs(turned.centerY) < abs(base.centerY))
    }

    // MARK: - Aspect

    /// Width over height on screen, after `orientation`.
    private func shownRatio(_ crop: CropEdit, _ width: Int, _ height: Int, _ orientation: OrientationEdit = .up) -> Double {
        let ratio = crop.width * Double(width) / (crop.height * Double(height))
        return orientation.swapsDimensions ? 1 / ratio : ratio
    }

    @Test func squareOnALandscapePhotoIsSquare() {
        let crop = CropEdit().applyingAspect(.square, swapped: false, displayedWidth: 3000, displayedHeight: 2000, orientation: .up)
        #expect(abs(shownRatio(crop, 3000, 2000) - 1) < 1e-9)
        #expect(crop.aspect == .square)
    }

    @Test func swapping16x9OnALandscapePhotoGives9x16() {
        let crop = CropEdit().applyingAspect(.ratio16x9, swapped: true, displayedWidth: 4000, displayedHeight: 3000, orientation: .up)
        #expect(abs(shownRatio(crop, 4000, 3000) - 9.0 / 16) < 1e-9)
        #expect(crop.shownRatio(orientation: .up, imageWidth: 4000, imageHeight: 3000).map { abs($0 - 9.0 / 16) < 1e-9 } == true)
    }

    @Test func aPendingQuarterTurnIsFollowedAsShown() {
        let plain = CropEdit().applyingAspect(.ratio16x9, swapped: false, displayedWidth: 4000, displayedHeight: 3000, orientation: .right)
        #expect(abs(shownRatio(plain, 4000, 3000, .right) - 9.0 / 16) < 1e-9)

        let swapped = CropEdit().applyingAspect(.ratio16x9, swapped: true, displayedWidth: 4000, displayedHeight: 3000, orientation: .right)
        #expect(abs(shownRatio(swapped, 4000, 3000, .right) - 16.0 / 9) < 1e-9)
    }

    @Test func custom2x1Is2x1AsShownUnderAQuarterTurn() {
        let crop = CropEdit(customWidth: 2, customHeight: 1)
            .applyingAspect(.custom, swapped: false, displayedWidth: 4000, displayedHeight: 3000, orientation: .right)

        #expect(abs(shownRatio(crop, 4000, 3000, .right) - 2) < 1e-9)
        #expect(crop.aspect == .custom && crop.customWidth == 2 && crop.customHeight == 1)
        #expect(crop.shownRatio(orientation: .right, imageWidth: 4000, imageHeight: 3000).map { abs($0 - 2) < 1e-9 } == true)
    }

    @Test func freeformAndAnUnsetCustomKeepTheFrameAndHoldNoRatio() {
        let frame = CropEdit(centerX: 0.1, width: 0.5, height: 0.3, straighten: 4, aspect: .square)

        let free = frame.applyingAspect(.freeform, swapped: false, displayedWidth: 3000, displayedHeight: 2000, orientation: .up)
        #expect(free == CropEdit(centerX: 0.1, width: 0.5, height: 0.3, straighten: 4, aspect: .freeform))
        #expect(free.shownRatio(orientation: .up, imageWidth: 3000, imageHeight: 2000) == nil)

        let custom = frame.applyingAspect(.custom, swapped: false, displayedWidth: 3000, displayedHeight: 2000, orientation: .up)
        #expect(custom.width == 0.5 && custom.aspect == .custom)
        #expect(custom.shownRatio(orientation: .up, imageWidth: 3000, imageHeight: 2000) == nil)
    }

    @Test func originalIsThePicturesShapeAsShownAndSwapsToItsInverse() {
        let original = CropEdit(straighten: 5)
            .applyingAspect(.original, swapped: false, displayedWidth: 3000, displayedHeight: 2000, orientation: .right)
        #expect(abs(shownRatio(original, 3000, 2000, .right) - 2.0 / 3) < 1e-9)
        #expect(original.straighten == 5)

        let swapped = CropEdit().applyingAspect(.original, swapped: true, displayedWidth: 3000, displayedHeight: 2000, orientation: .up)
        #expect(abs(shownRatio(swapped, 3000, 2000) - 2.0 / 3) < 1e-9)
    }
}
