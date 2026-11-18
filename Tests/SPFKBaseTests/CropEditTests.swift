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
}
