// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation

/// A crop as Adobe Camera Raw and Lightroom store it in `crs:CropTop`, `CropLeft`, `CropBottom`,
/// `CropRight` and `CropAngle`.
///
/// Everything is in the file's stored pixels, before its orientation tag, as 0-1 fractions, y down.
/// `(left, top)` and `(right, bottom)` are the crop rectangle's own top-left and bottom-right
/// corners, not its bounding box. ``angle`` is degrees; the rectangle's x axis in stored pixels is
/// `(cos angle, sin angle)`.
public struct CameraRawCrop: Sendable, Hashable, Codable {
    public var top: Double
    public var left: Double
    public var bottom: Double
    public var right: Double
    public var angle: Double

    public init(top: Double, left: Double, bottom: Double, right: Double, angle: Double) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
        self.angle = angle
    }

    /// `crop`, drawn on the displayed picture of a `storedWidth × storedHeight` file tagged
    /// `fileOrientation`. A crop reaching outside the picture is written as the part it keeps.
    public init(_ crop: CropEdit, storedWidth: Int, storedHeight: Int, fileOrientation: Int) {
        let stored = crop.unoriented(fileOrientation: fileOrientation)
            .contained(imageWidth: storedWidth, imageHeight: storedHeight)
        let corners = stored.corners(imageWidth: storedWidth, imageHeight: storedHeight)
        let width = Double(storedWidth)
        let height = Double(storedHeight)

        self.init(
            top: corners[0].y / height,
            left: corners[0].x / width,
            bottom: corners[2].y / height,
            right: corners[2].x / width,
            angle: stored.straighten == 0 ? 0 : -stored.straighten
        )
    }

    /// The inverse of ``init(_:storedWidth:storedHeight:fileOrientation:)``, as Freeform.
    public func cropEdit(storedWidth: Int, storedHeight: Int, fileOrientation: Int) -> CropEdit {
        let width = Double(storedWidth)
        let height = Double(storedHeight)
        guard width > 0, height > 0 else { return CropEdit() }

        let topLeft = SIMD2(left * width, top * height)
        let bottomRight = SIMD2(right * width, bottom * height)
        let center = (topLeft + bottomRight) / 2
        let diagonal = bottomRight - topLeft

        let radians = angle * .pi / 180
        let xAxis = SIMD2(cos(radians), sin(radians))
        let yAxis = SIMD2(-sin(radians), cos(radians))

        return CropEdit(
            centerX: center.x / width - 0.5,
            centerY: center.y / height - 0.5,
            width: (diagonal * xAxis).sum() / width,
            height: (diagonal * yAxis).sum() / height,
            straighten: angle == 0 ? 0 : -angle
        ).oriented(fileOrientation: fileOrientation)
    }
}
