// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation

/// A picture as an interactive crop shows it: the upright picture under its pending orientation,
/// turned by its straighten, with the kept rectangle axis-aligned over it.
///
/// In shown pixels, y down, with the origin at the top left of the turned picture's bounding box.
public struct CropCanvas: Sendable, Equatable {
    public let crop: CropEdit
    /// The displayed size: the upright decode, before ``orientation``.
    public let imageWidth: Int
    public let imageHeight: Int
    public let orientation: OrientationEdit

    public init(crop: CropEdit, imageWidth: Int, imageHeight: Int, orientation: OrientationEdit) {
        self.crop = crop
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.orientation = orientation
    }

    /// The picture as shown, before the turn.
    public var shownSize: SIMD2<Double> {
        orientation.swapsDimensions
            ? SIMD2(Double(imageHeight), Double(imageWidth))
            : SIMD2(Double(imageWidth), Double(imageHeight))
    }

    /// Degrees clockwise on screen. A mirror after the straighten reverses its direction.
    public var shownAngle: Double {
        orientation.isMirrored ? -crop.straighten : crop.straighten
    }

    /// The turned picture's bounding box.
    public var boundingSize: SIMD2<Double> {
        let size = shownSize
        let (c, s) = cosSin
        return SIMD2(size.x * abs(c) + size.y * abs(s), size.x * abs(s) + size.y * abs(c))
    }

    /// The turned picture's corners: its top left, top right, bottom right and bottom left as shown.
    public var pictureCorners: [SIMD2<Double>] {
        let size = shownSize
        return [SIMD2(0, 0), SIMD2(size.x, 0), size, SIMD2(0, size.y)].map(turned)
    }

    /// The kept rectangle's size, axis-aligned in the canvas. Unrounded, so it maps back exactly.
    public var frameSize: SIMD2<Double> {
        let width = crop.width * Double(imageWidth)
        let height = crop.height * Double(imageHeight)
        return orientation.swapsDimensions ? SIMD2(height, width) : SIMD2(width, height)
    }

    public var frameCenter: SIMD2<Double> {
        let displayed = SIMD2(0.5 + crop.centerX, 0.5 + crop.centerY)
        return turned(orientation.shownUnitPoint(forDisplayed: displayed) * shownSize)
    }

    /// A frame in canvas pixels as a crop, keeping `base`'s straighten, aspect and custom ratio.
    public func crop(frameCenter: SIMD2<Double>, frameSize: SIMD2<Double>, base: CropEdit) -> CropEdit {
        let size = shownSize
        guard size.x > 0, size.y > 0 else { return base }

        let shown = unturned(frameCenter) / size
        let displayed = orientation.displayedUnitPoint(forShown: shown)
        let displayedSize = orientation.swapsDimensions ? SIMD2(frameSize.y, frameSize.x) : frameSize

        return CropEdit(
            centerX: displayed.x - 0.5,
            centerY: displayed.y - 0.5,
            width: displayedSize.x / Double(imageWidth),
            height: displayedSize.y / Double(imageHeight),
            straighten: base.straighten,
            aspect: base.aspect,
            customWidth: base.customWidth,
            customHeight: base.customHeight
        )
    }

    // MARK: - Turning

    private var cosSin: (Double, Double) {
        let radians = shownAngle * .pi / 180
        return (cos(radians), sin(radians))
    }

    /// A point of the unturned shown picture, turned clockwise about its center into the canvas.
    private func turned(_ point: SIMD2<Double>) -> SIMD2<Double> {
        let (c, s) = cosSin
        let v = point - shownSize / 2
        return SIMD2(c * v.x - s * v.y, s * v.x + c * v.y) + boundingSize / 2
    }

    private func unturned(_ point: SIMD2<Double>) -> SIMD2<Double> {
        let (c, s) = cosSin
        let v = point - boundingSize / 2
        return SIMD2(c * v.x + s * v.y, -s * v.x + c * v.y) + shownSize / 2
    }
}
