// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SPFKBase
import Testing

struct CropCanvasTests {
    static let width = 3000
    static let height = 2000

    static let straightens: [Double] = [0, 7, -20]

    /// A centered and an off-center crop at `straighten`, each inside the picture.
    static func crops(straighten: Double) -> [CropEdit] {
        [
            CropEdit(width: 0.6, height: 0.5, straighten: straighten),
            CropEdit(centerX: 0.12, centerY: -0.09, width: 0.4, height: 0.35, straighten: straighten),
        ].map { $0.contained(imageWidth: width, imageHeight: height) }
    }

    private func isClose(_ a: Double, _ b: Double, _ tolerance: Double = 1e-9) -> Bool {
        abs(a - b) < tolerance
    }

    @Test(arguments: OrientationEdit.allCases)
    func aFrameMapsBackToTheSameCrop(orientation: OrientationEdit) {
        for straighten in Self.straightens {
            for crop in Self.crops(straighten: straighten) {
                let canvas = CropCanvas(crop: crop, imageWidth: Self.width, imageHeight: Self.height, orientation: orientation)
                let back = canvas.crop(frameCenter: canvas.frameCenter, frameSize: canvas.frameSize, base: crop)

                #expect(isClose(back.centerX, crop.centerX) && isClose(back.centerY, crop.centerY), "\(orientation) \(straighten)°")
                #expect(isClose(back.width, crop.width) && isClose(back.height, crop.height), "\(orientation) \(straighten)°")
                #expect(back.straighten == crop.straighten && back.aspect == crop.aspect)
            }
        }
    }

    @Test func theBoundingBoxIsThePictureUnturnedAndGrowsToItsDiagonalAt45Degrees() {
        let flat = CropCanvas(crop: CropEdit(), imageWidth: Self.width, imageHeight: Self.height, orientation: .right)
        #expect(flat.boundingSize == flat.shownSize)
        #expect(flat.shownSize == SIMD2(2000, 3000))

        let turned = CropCanvas(crop: CropEdit(straighten: 45), imageWidth: Self.width, imageHeight: Self.height, orientation: .up)
        let side = Double(Self.width + Self.height) / 2.squareRoot()
        #expect(isClose(turned.boundingSize.x, side, 1e-6) && isClose(turned.boundingSize.y, side, 1e-6))
    }

    /// A mirror reverses the turn as shown.
    @Test func aMirrorNegatesTheShownAngle() {
        let crop = CropEdit(straighten: 7)

        for orientation in OrientationEdit.allCases {
            let canvas = CropCanvas(crop: crop, imageWidth: Self.width, imageHeight: Self.height, orientation: orientation)
            #expect(canvas.shownAngle == (orientation.isMirrored ? -7 : 7), "\(orientation)")
        }
    }

    /// The turned picture is the overlay's boundary, so a contained crop's frame lies inside it.
    @Test(arguments: OrientationEdit.allCases)
    func aContainedCropsFrameIsInsideThePicture(orientation: OrientationEdit) {
        for straighten in Self.straightens + [30, -44] {
            for crop in Self.crops(straighten: straighten) {
                let canvas = CropCanvas(crop: crop, imageWidth: Self.width, imageHeight: Self.height, orientation: orientation)
                let half = canvas.frameSize / 2
                let corners = [SIMD2(-half.x, -half.y), SIMD2(half.x, -half.y), half, SIMD2(-half.x, half.y)].map { canvas.frameCenter + $0 }

                for corner in corners {
                    #expect(Self.isInside(corner, polygon: canvas.pictureCorners), "\(orientation) \(straighten)°")
                }
            }
        }
    }

    /// Inside or on the edge of a convex polygon given clockwise on screen (y down).
    static func isInside(_ point: SIMD2<Double>, polygon: [SIMD2<Double>], tolerance: Double = 1e-6) -> Bool {
        for (index, a) in polygon.enumerated() {
            let b = polygon[(index + 1) % polygon.count]
            let edge = b - a
            let toPoint = point - a
            let cross = edge.x * toPoint.y - edge.y * toPoint.x
            let length = (edge.x * edge.x + edge.y * edge.y).squareRoot()
            if cross < -tolerance * length { return false }
        }
        return true
    }
}
