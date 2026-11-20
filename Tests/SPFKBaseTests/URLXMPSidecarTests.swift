import Foundation
@testable import SPFKBase
import SPFKTesting
import Testing

@Suite(.tags(.file, .xmpSidecar))
final class URLXMPSidecarTests: BinTestCase {
    @Test(arguments: ["raf", "RAF", "cr3", "nef", "arw"])
    func cameraRAWUsesASidecar(pathExtension: String) {
        #expect(URL(fileURLWithPath: "/x/DSCF3303.\(pathExtension)").usesXMPSidecar)
    }

    @Test(arguments: ["dng", "DNG", "jpg", "mp4", "xmp", ""])
    func otherFilesDoNot(pathExtension: String) {
        #expect(!URL(fileURLWithPath: "/x/DSCF3303.\(pathExtension)").usesXMPSidecar)
    }

    @Test func absentSidecarIsNamedInLowerCase() {
        let raw = bin.appendingPathComponent("DSCF3303.RAF")
        #expect(raw.xmpSidecarURL == bin.appendingPathComponent("DSCF3303.xmp"))
        #expect(raw.existingXMPSidecarURL == nil)
    }

    @Test func existingUpperCaseSidecarIsFound() throws {
        let raw = bin.appendingPathComponent("DSCF3303.RAF")
        let sidecar = bin.appendingPathComponent("DSCF3303.XMP")
        try Data().write(to: raw)
        try Data().write(to: sidecar)

        #expect(raw.xmpSidecarURL.lastPathComponent == "DSCF3303.XMP")
        #expect(raw.existingXMPSidecarURL?.lastPathComponent == "DSCF3303.XMP")
    }

    @Test func aDNGNeverReportsAnExistingSidecar() throws {
        let dng = bin.appendingPathComponent("DSCF0060.dng")
        try Data().write(to: bin.appendingPathComponent("DSCF0060.xmp"))
        #expect(dng.existingXMPSidecarURL == nil)
    }

    @Test func dottedBaseNameKeepsItsDots() {
        let raw = bin.appendingPathComponent("trip.day1.RAF")
        #expect(raw.xmpSidecarURL.lastPathComponent == "trip.day1.xmp")
    }
}
