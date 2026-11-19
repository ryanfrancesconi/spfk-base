// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation

extension CropEdit {
    /// This crop at `shownAngle` degrees clockwise on screen, shrunk only as far as it must be to stay
    /// inside the turned picture.
    ///
    /// Call it on the crop a gesture began with, never on the previous step, so turning back restores
    /// it. Where shrinking would leave less than half its size, the center moves toward the picture's
    /// center instead, as little as keeps half.
    public func straightened(to shownAngle: Double, orientation: OrientationEdit, imageWidth: Int, imageHeight: Int) -> CropEdit {
        var turned = self
        turned.straighten = orientation.isMirrored ? -shownAngle : shownAngle
        turned = turned.sanitized

        func contained(at t: Double) -> CropEdit {
            var moved = turned
            moved.centerX = turned.centerX * (1 - t)
            moved.centerY = turned.centerY * (1 - t)
            return moved.contained(imageWidth: imageWidth, imageHeight: imageHeight)
        }

        func keepsHalf(_ crop: CropEdit) -> Bool {
            crop.width >= turned.width / 2 - 1e-12 && crop.height >= turned.height / 2 - 1e-12
        }

        let inPlace = contained(at: 0)
        guard !keepsHalf(inPlace) else { return inPlace }

        let centered = contained(at: 1)
        guard keepsHalf(centered) else { return centered }

        var low = 0.0
        var high = 1.0

        for _ in 0 ..< 16 {
            let middle = (low + high) / 2
            if keepsHalf(contained(at: middle)) {
                high = middle
            } else {
                low = middle
            }
        }

        return contained(at: high)
    }

    /// The crop `aspect` gives: the largest centered one of its ratio at this straighten, as shown under
    /// `orientation`, or the inverse ratio when `swapped`. `.custom` uses ``customRatio`` as shown and,
    /// like `.freeform`, keeps this frame when there is no ratio to hold.
    public func applyingAspect(
        _ aspect: CropAspect,
        swapped: Bool,
        displayedWidth: Int,
        displayedHeight: Int,
        orientation: OrientationEdit
    ) -> CropEdit {
        var result: CropEdit

        switch aspect {
        case .freeform:
            result = self

        case .custom:
            guard let shown = customRatio else {
                result = self
                break
            }

            let ratio = swapped ? 1 / shown : shown
            result = Self.largestCentered(
                aspect: orientation.swapsDimensions ? 1 / ratio : ratio,
                imageWidth: displayedWidth,
                imageHeight: displayedHeight,
                straighten: straighten
            )

        default:
            result = Self.cropping(
                to: aspect,
                displayedWidth: displayedWidth,
                displayedHeight: displayedHeight,
                pendingOrientation: orientation,
                straighten: straighten,
                swapped: swapped
            )
        }

        result.aspect = aspect
        result.customWidth = customWidth
        result.customHeight = customHeight
        return result
    }

    /// The ratio a drag must hold, width over height on screen, or nil when the frame is free. A fixed
    /// ratio is read from the frame itself, so it keeps whichever way round it was swapped.
    public func shownRatio(orientation: OrientationEdit, imageWidth: Int, imageHeight: Int) -> Double? {
        switch aspect {
        case .freeform: return nil
        case .custom where customRatio == nil: return nil
        default: break
        }

        let width = self.width * Double(imageWidth)
        let height = self.height * Double(imageHeight)
        guard width > 0, height > 0 else { return nil }

        return orientation.swapsDimensions ? height / width : width / height
    }
}
