// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation

/// A pending crop and straighten of a still image, in the image's displayed space: the upright
/// picture, before any pending ``OrientationEdit``. Clamped on construction.
///
/// The kept region is a rectangle of `width × W` by `height × H` pixels for a `W × H` image, centered
/// at the offset center and turned by ``straighten`` about its own center. Because the two fractions
/// are of different lengths, every rotation is computed in pixels.
public struct CropEdit: Codable, Sendable, Hashable {
    /// The kept rectangle's center, as an offset from the image's center in fractions of the displayed
    /// width and height; right and down are positive.
    public var centerX: Double
    public var centerY: Double

    /// The kept rectangle's size, as fractions of the displayed width and height.
    public var width: Double
    public var height: Double

    /// Degrees. Positive turns the picture clockwise as displayed.
    public var straighten: Double

    /// The constraint the user chose. Not geometry: ``isIdentity`` ignores it.
    public var aspect: CropAspect

    public init(
        centerX: Double = 0,
        centerY: Double = 0,
        width: Double = 1,
        height: Double = 1,
        straighten: Double = 0,
        aspect: CropAspect = .freeform
    ) {
        self.centerX = Self.sanitize(centerX, default: 0, in: Self.centerRange)
        self.centerY = Self.sanitize(centerY, default: 0, in: Self.centerRange)
        self.width = Self.sanitize(width, default: 1, in: Self.sizeRange)
        self.height = Self.sanitize(height, default: 1, in: Self.sizeRange)
        self.straighten = Self.sanitize(straighten, default: 0, in: Self.straightenRange)
        self.aspect = aspect
    }

    public static let centerRange: ClosedRange<Double> = -0.5 ... 0.5
    public static let sizeRange: ClosedRange<Double> = 0.01 ... 1
    public static let straightenRange: ClosedRange<Double> = -45 ... 45

    /// The whole picture, unturned.
    public var isIdentity: Bool {
        width == 1 && height == 1 && centerX == 0 && centerY == 0 && straighten == 0
    }

    /// This value with each field clamped, as the initializer clamps it.
    public var sanitized: Self {
        Self(centerX: centerX, centerY: centerY, width: width, height: height, straighten: straighten, aspect: aspect)
    }

    private static func sanitize(_ value: Double, default fallback: Double, in range: ClosedRange<Double>) -> Double {
        guard value.isFinite else { return fallback }
        return min(max(value, range.lowerBound), range.upperBound)
    }

    // MARK: - Geometry

    /// The kept rectangle's size in whole pixels for a `imageWidth × imageHeight` image. The one
    /// rounding rule for a crop's output size.
    public func pixelSize(imageWidth: Int, imageHeight: Int) -> (width: Int, height: Int) {
        (
            width: max(1, Int((width * Double(imageWidth)).rounded())),
            height: max(1, Int((height * Double(imageHeight)).rounded()))
        )
    }

    /// The kept rectangle's center in pixels, from the image's top left, y down.
    public func pixelCenter(imageWidth: Int, imageHeight: Int) -> SIMD2<Double> {
        SIMD2((0.5 + centerX) * Double(imageWidth), (0.5 + centerY) * Double(imageHeight))
    }

    /// The kept rectangle's corners in the picture, in pixels from its top left, y down: top left,
    /// top right, bottom right, bottom left of the output.
    public func corners(imageWidth: Int, imageHeight: Int) -> [SIMD2<Double>] {
        let center = pixelCenter(imageWidth: imageWidth, imageHeight: imageHeight)
        return cornerOffsets(imageWidth: imageWidth, imageHeight: imageHeight).map { center + $0 }
    }

    /// The picture turns clockwise, so the frame turns counterclockwise over it.
    private func cornerOffsets(imageWidth: Int, imageHeight: Int) -> [SIMD2<Double>] {
        let halfWidth = width * Double(imageWidth) / 2
        let halfHeight = height * Double(imageHeight) / 2
        let radians = straighten * .pi / 180
        let c = cos(radians)
        let s = sin(radians)

        return [(-halfWidth, -halfHeight), (halfWidth, -halfHeight), (halfWidth, halfHeight), (-halfWidth, halfHeight)].map { dx, dy in
            SIMD2(c * dx + s * dy, -s * dx + c * dy)
        }
    }

    /// This crop shrunk about its own center so its corners lie inside the image. One crop already
    /// inside is returned unchanged.
    public func contained(imageWidth: Int, imageHeight: Int) -> CropEdit {
        let center = pixelCenter(imageWidth: imageWidth, imageHeight: imageHeight)
        let limits = SIMD2(Double(imageWidth), Double(imageHeight))
        var scale = 1.0

        for offset in cornerOffsets(imageWidth: imageWidth, imageHeight: imageHeight) {
            for axis in 0 ..< 2 where offset[axis] != 0 {
                let room = offset[axis] > 0 ? limits[axis] - center[axis] : center[axis]
                scale = min(scale, max(0, room) / abs(offset[axis]))
            }
        }

        guard scale < 1 else { return self }

        var result = self
        result.width = width * scale
        result.height = height * scale
        return result.sanitized
    }

    /// The largest centered rectangle of pixel aspect `aspect` (width over height) inside the image
    /// turned by `straighten` degrees.
    public static func largestCentered(aspect: Double, imageWidth: Int, imageHeight: Int, straighten: Double = 0) -> CropEdit {
        let straighten = sanitize(straighten, default: 0, in: straightenRange)
        let width = Double(imageWidth)
        let height = Double(imageHeight)

        guard aspect.isFinite, aspect > 0, width > 0, height > 0 else { return CropEdit(straighten: straighten) }

        let radians = straighten * .pi / 180
        let c = abs(cos(radians))
        let s = abs(sin(radians))
        let keptHeight = min(width / (aspect * c + s), height / (aspect * s + c))

        return CropEdit(width: aspect * keptHeight / width, height: keptHeight / height, straighten: straighten)
    }

    /// The largest centered crop of `aspect` for an image displayed `displayedWidth × displayedHeight`
    /// before `pendingOrientation`. The ratio follows the picture as shown, the pending orientation
    /// included: a landscape picture gets 16:9, a portrait one 9:16. `.original` and `.freeform` keep
    /// the picture's own shape.
    public static func cropping(
        to aspect: CropAspect,
        displayedWidth: Int,
        displayedHeight: Int,
        pendingOrientation: OrientationEdit = .up,
        straighten: Double = 0
    ) -> CropEdit {
        let ratio: Double

        if let landscape = aspect.landscapeRatio {
            let swaps = pendingOrientation.swapsDimensions
            let shownWidth = swaps ? displayedHeight : displayedWidth
            let shownHeight = swaps ? displayedWidth : displayedHeight
            let shown = shownWidth >= shownHeight ? landscape : 1 / landscape
            ratio = swaps ? 1 / shown : shown
        } else {
            ratio = displayedHeight > 0 ? Double(displayedWidth) / Double(displayedHeight) : 1
        }

        var result = largestCentered(aspect: ratio, imageWidth: displayedWidth, imageHeight: displayedHeight, straighten: straighten)
        result.aspect = aspect
        return result
    }
}

/// The shape a crop is held to.
public enum CropAspect: String, Codable, Sendable, CaseIterable {
    case freeform
    case original
    case square
    case ratio16x9
    case ratio4x5
    case ratio5x7
    case ratio4x3
    case ratio3x5
    case ratio3x2

    /// Width over height with the longer side horizontal; nil for ``freeform`` and ``original``.
    public var landscapeRatio: Double? {
        switch self {
        case .freeform, .original: nil
        case .square: 1
        case .ratio16x9: 16.0 / 9
        case .ratio4x5: 5.0 / 4
        case .ratio5x7: 7.0 / 5
        case .ratio4x3: 4.0 / 3
        case .ratio3x5: 5.0 / 3
        case .ratio3x2: 3.0 / 2
        }
    }
}
