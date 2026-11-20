// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SPFKBase
import Testing

/// A crop converted to and from Adobe Camera Raw's `crs:Crop*` settings.
struct CameraRawCropTests {
    /// Crops Lightroom Classic 16.0.1 wrote, with the size it reported for each, as displayed.
    struct LightroomCase: CustomTestStringConvertible, Sendable {
        let name: String
        let storedWidth: Int
        let storedHeight: Int
        let orientation: Int
        let crop: CameraRawCrop
        let displayedWidth: Int
        let displayedHeight: Int

        var testDescription: String { name }
    }

    static let lightroomCases: [LightroomCase] = [
        LightroomCase(
            name: "A.RAF", storedWidth: 4896, storedHeight: 3264, orientation: 1,
            crop: CameraRawCrop(top: 0.158675, left: 0.122303, bottom: 1, right: 1, angle: 0),
            displayedWidth: 4297, displayedHeight: 2746
        ),
        LightroomCase(
            name: "B.RAF", storedWidth: 4896, storedHeight: 3264, orientation: 1,
            crop: CameraRawCrop(top: 0.15612, left: 0.091829, bottom: 0.886367, right: 0.999618, angle: -5),
            displayedWidth: 4220, displayedHeight: 2762
        ),
        LightroomCase(
            name: "F.RAF", storedWidth: 4896, storedHeight: 3264, orientation: 1,
            crop: CameraRawCrop(top: 0.157474, left: 0.146154, bottom: 1, right: 1, angle: 0),
            displayedWidth: 4180, displayedHeight: 2750
        ),
        LightroomCase(
            name: "G.RAF", storedWidth: 4896, storedHeight: 3264, orientation: 2,
            crop: CameraRawCrop(top: 0.153693, left: 0, bottom: 0.876581, right: 0.989819, angle: -5),
            displayedWidth: 4622, displayedHeight: 2773
        ),
        LightroomCase(
            name: "C.dng", storedWidth: 6000, storedHeight: 4000, orientation: 8,
            crop: CameraRawCrop(top: 0.163003, left: 0.036255, bottom: 0.836997, right: 0.865815, angle: -5),
            displayedWidth: 3120, displayedHeight: 4723
        ),
    ]

    @Test(arguments: lightroomCases)
    func aLightroomCropKeepsTheSizeLightroomReports(sample: LightroomCase) {
        let swaps = OrientationEdit(rawValue: sample.orientation)?.swapsDimensions == true
        let displayedWidth = swaps ? sample.storedHeight : sample.storedWidth
        let displayedHeight = swaps ? sample.storedWidth : sample.storedHeight

        let crop = sample.crop.cropEdit(
            storedWidth: sample.storedWidth, storedHeight: sample.storedHeight, fileOrientation: sample.orientation
        )
        let kept = crop.keptPixelSize(imageWidth: displayedWidth, imageHeight: displayedHeight)

        #expect(abs(kept.width - sample.displayedWidth) <= 1, "\(kept)")
        #expect(abs(kept.height - sample.displayedHeight) <= 1, "\(kept)")
    }

    @Test func anUnmirroredAngleIsTheNegatedStraighten() {
        let crop = Self.lightroomCases[1].crop.cropEdit(storedWidth: 4896, storedHeight: 3264, fileOrientation: 1)
        #expect(abs(crop.straighten - 5) < 1e-9)
    }

    static let crops: [CropEdit] = [
        CropEdit(centerX: 0.1, centerY: -0.15, width: 0.5, height: 0.4),
        CropEdit(centerX: 0.1, centerY: -0.15, width: 0.5, height: 0.4, straighten: 7),
        CropEdit(centerX: -0.05, centerY: 0.08, width: 0.6, height: 0.55, straighten: -12),
    ]

    @Test(arguments: OrientationEdit.allCases, crops)
    func aCropSurvivesTheRoundTrip(tag: OrientationEdit, crop: CropEdit) {
        let storedWidth = 4896
        let storedHeight = 3264

        let raw = CameraRawCrop(crop, storedWidth: storedWidth, storedHeight: storedHeight, fileOrientation: tag.rawValue)
        let back = raw.cropEdit(storedWidth: storedWidth, storedHeight: storedHeight, fileOrientation: tag.rawValue)

        #expect(abs(back.centerX - crop.centerX) < 1e-6, "\(back)")
        #expect(abs(back.centerY - crop.centerY) < 1e-6, "\(back)")
        #expect(abs(back.width - crop.width) < 1e-6, "\(back)")
        #expect(abs(back.height - crop.height) < 1e-6, "\(back)")
        #expect(abs(back.straighten - crop.straighten) < 1e-6, "\(back)")
    }

    @Test(arguments: OrientationEdit.allCases)
    func theWholePictureIsTheWholeFrame(tag: OrientationEdit) {
        let raw = CameraRawCrop(CropEdit(), storedWidth: 6000, storedHeight: 4000, fileOrientation: tag.rawValue)

        #expect(abs(raw.top) < 1e-12)
        #expect(abs(raw.left) < 1e-12)
        #expect(abs(raw.bottom - 1) < 1e-12)
        #expect(abs(raw.right - 1) < 1e-12)
        #expect(raw.angle == 0)
    }

    @Test func aCropReachingOutsideThePictureIsWrittenAsWhatIsKept() {
        let crop = CropEdit(width: 0.9, height: 0.9, straighten: 20)
        let raw = CameraRawCrop(crop, storedWidth: 600, storedHeight: 400, fileOrientation: 1)
        let back = raw.cropEdit(storedWidth: 600, storedHeight: 400, fileOrientation: 1)

        let kept = crop.keptPixelSize(imageWidth: 600, imageHeight: 400)
        #expect(back.pixelSize(imageWidth: 600, imageHeight: 400) == kept)
    }
}
