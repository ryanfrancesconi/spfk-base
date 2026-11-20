// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation

extension CropEdit {
    /// The same kept region in the stored pixels of a file tagged `fileOrientation`, whose tag turns
    /// those pixels into the displayed picture this crop is in. An out-of-range tag reads as 1.
    public func unoriented(fileOrientation: Int) -> CropEdit {
        let tag = OrientationEdit(rawValue: fileOrientation) ?? .up
        guard !tag.isIdentity else { return self }

        let center = tag.displayedUnitPoint(forShown: SIMD2(0.5 + centerX, 0.5 + centerY))
        let swaps = tag.swapsDimensions

        return CropEdit(
            centerX: center.x - 0.5,
            centerY: center.y - 0.5,
            width: swaps ? height : width,
            height: swaps ? width : height,
            straighten: tag.isMirrored ? -straighten : straighten,
            aspect: aspect,
            customWidth: customWidth,
            customHeight: customHeight
        )
    }

    /// The inverse of ``unoriented(fileOrientation:)``: a crop of a file's stored pixels, in the
    /// displayed picture its tag `fileOrientation` makes of them.
    public func oriented(fileOrientation: Int) -> CropEdit {
        let tag = OrientationEdit(rawValue: fileOrientation) ?? .up
        guard !tag.isIdentity else { return self }

        let center = tag.shownUnitPoint(forDisplayed: SIMD2(0.5 + centerX, 0.5 + centerY))
        let swaps = tag.swapsDimensions

        return CropEdit(
            centerX: center.x - 0.5,
            centerY: center.y - 0.5,
            width: swaps ? height : width,
            height: swaps ? width : height,
            straighten: tag.isMirrored ? -straighten : straighten,
            aspect: aspect,
            customWidth: customWidth,
            customHeight: customHeight
        )
    }

    /// The size SPFKImage's `apply(to:)` produces for a `imageWidth × imageHeight` image: the crop
    /// ``contained(imageWidth:imageHeight:)``, then ``pixelSize(imageWidth:imageHeight:)``.
    public func keptPixelSize(imageWidth: Int, imageHeight: Int) -> (width: Int, height: Int) {
        contained(imageWidth: imageWidth, imageHeight: imageHeight).pixelSize(imageWidth: imageWidth, imageHeight: imageHeight)
    }
}
