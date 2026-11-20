// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SPFKBase
import Testing

/// A crop drawn on the displayed picture, mapped into a file's stored pixels.
struct CropEditOrientationTests {
    static let crops: [CropEdit] = [
        CropEdit(centerX: 0.1, centerY: -0.15, width: 0.5, height: 0.4),
        CropEdit(centerX: 0.1, centerY: -0.15, width: 0.5, height: 0.4, straighten: 7),
        CropEdit(width: 0.333, height: 0.333, straighten: -20),
    ]

    static let sizes: [(width: Int, height: Int)] = [(600, 400), (4032, 3024), (1001, 667)]

    /// A displayed pixel, in the stored pixels of a file `tag` displays.
    private func storedPoint(_ point: SIMD2<Double>, tag: OrientationEdit, storedWidth: Int, storedHeight: Int) -> SIMD2<Double> {
        let displayedWidth = Double(tag.swapsDimensions ? storedHeight : storedWidth)
        let displayedHeight = Double(tag.swapsDimensions ? storedWidth : storedHeight)
        let unit = tag.displayedUnitPoint(forShown: SIMD2(point.x / displayedWidth, point.y / displayedHeight))
        return SIMD2(unit.x * Double(storedWidth), unit.y * Double(storedHeight))
    }

    @Test(arguments: OrientationEdit.allCases, crops)
    func theUnorientedCropKeepsTheSameCorners(tag: OrientationEdit, crop: CropEdit) {
        let storedWidth = 600
        let storedHeight = 400
        let displayedWidth = tag.swapsDimensions ? storedHeight : storedWidth
        let displayedHeight = tag.swapsDimensions ? storedWidth : storedHeight

        let expected = crop.corners(imageWidth: displayedWidth, imageHeight: displayedHeight)
            .map { storedPoint($0, tag: tag, storedWidth: storedWidth, storedHeight: storedHeight) }
        let actual = crop.unoriented(fileOrientation: tag.rawValue).corners(imageWidth: storedWidth, imageHeight: storedHeight)

        for corner in expected {
            let nearest = actual.map { (($0 - corner) * ($0 - corner)).sum() }.min() ?? .infinity
            #expect(nearest.squareRoot() < 1e-9, "\(tag) \(corner) against \(actual)")
        }
    }

    @Test(arguments: OrientationEdit.allCases, crops)
    func theKeptSizeFollowsTheTag(tag: OrientationEdit, crop: CropEdit) {
        let stored = crop.unoriented(fileOrientation: tag.rawValue)

        for size in Self.sizes {
            let displayedWidth = tag.swapsDimensions ? size.height : size.width
            let displayedHeight = tag.swapsDimensions ? size.width : size.height
            let shown = crop.keptPixelSize(imageWidth: displayedWidth, imageHeight: displayedHeight)
            let kept = stored.keptPixelSize(imageWidth: size.width, imageHeight: size.height)

            #expect(kept.width == (tag.swapsDimensions ? shown.height : shown.width), "\(tag) \(size)")
            #expect(kept.height == (tag.swapsDimensions ? shown.width : shown.height), "\(tag) \(size)")
        }
    }

    @Test func anOutOfRangeTagReadsAsUpright() {
        let crop = Self.crops[1]
        #expect(crop.unoriented(fileOrientation: 0) == crop)
        #expect(crop.unoriented(fileOrientation: 9) == crop)
    }

    @Test func aCropReachingOutsideThePictureKeepsLessThanItsPixelSize() {
        let crop = CropEdit(width: 0.9, height: 0.9, straighten: 20)
        let kept = crop.keptPixelSize(imageWidth: 600, imageHeight: 400)
        let full = crop.pixelSize(imageWidth: 600, imageHeight: 400)

        #expect(kept.width < full.width)
        #expect(kept.height < full.height)
    }

    @Test(arguments: OrientationEdit.allCases)
    func theAspectAndCustomSidesDoNotChangeTheGeometry(tag: OrientationEdit) {
        let plain = CropEdit(centerX: 0.1, centerY: -0.15, width: 0.5, height: 0.4, straighten: 7)
        let constrained = CropEdit(
            centerX: 0.1, centerY: -0.15, width: 0.5, height: 0.4, straighten: 7,
            aspect: .custom, customWidth: 3, customHeight: 7
        )

        var a = plain.unoriented(fileOrientation: tag.rawValue)
        var b = constrained.unoriented(fileOrientation: tag.rawValue)
        #expect(b.aspect == .custom)
        #expect(b.customWidth == 3)
        a.aspect = .freeform
        b.aspect = .freeform
        b.customWidth = 0
        b.customHeight = 0
        #expect(a == b)

        let size = constrained.keptPixelSize(imageWidth: 1001, imageHeight: 667)
        let plainSize = plain.keptPixelSize(imageWidth: 1001, imageHeight: 667)
        #expect(size == plainSize)
    }
}

extension CropEditOrientationTests {
    @Test(arguments: OrientationEdit.allCases, crops)
    func orientingUndoesUnorienting(tag: OrientationEdit, crop: CropEdit) {
        let back = crop.unoriented(fileOrientation: tag.rawValue).oriented(fileOrientation: tag.rawValue)

        #expect(abs(back.centerX - crop.centerX) < 1e-12)
        #expect(abs(back.centerY - crop.centerY) < 1e-12)
        #expect(back.width == crop.width)
        #expect(back.height == crop.height)
        #expect(back.straighten == crop.straighten)
        #expect(back.aspect == crop.aspect)
    }
}
