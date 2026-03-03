import Foundation
@testable import SPFKBase
import Testing
import UniformTypeIdentifiers

@Suite("URL ResourceValues Extensions")
struct URLResourceValuesTests {
    @Test("mimeType for known extensions")
    func mimeType() {
        let mp3 = URL(fileURLWithPath: "/tmp/song.mp3")
        #expect(mp3.mimeType.contains("audio"))

        let txt = URL(fileURLWithPath: "/tmp/file.txt")
        #expect(txt.mimeType == "text/plain")

        let caf = URL(fileURLWithPath: "/tmp/file.caf")
        #expect(caf.mimeType == "audio/x-caf")
    }

    @Test("isDirectory for temp directory")
    func isDirectory() {
        let tmp = URL(fileURLWithPath: NSTemporaryDirectory())
        #expect(tmp.isDirectory)
    }

    @Test("isDirectory false for file")
    func isDirectoryFalseForFile() throws {
        let file = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("spfk_isdir_test_\(UUID().uuidString).txt")

        try "test".data(using: .utf8)!.write(to: file)
        defer { try? file.delete() }

        #expect(!file.isDirectory)
    }

    @Test("isHidden for dotfiles")
    func isHidden() {
        let hidden = URL(fileURLWithPath: "/tmp/.hidden")
        #expect(hidden.isHidden)

        let visible = URL(fileURLWithPath: "/tmp/visible.txt")
        #expect(!visible.isHidden)
    }

    @Test("creationDate for temp directory")
    func creationDate() {
        let tmp = URL(fileURLWithPath: NSTemporaryDirectory())
        #expect(tmp.creationDate != nil)
    }

    @Test("dates for written file")
    func fileDates() throws {
        let file = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("spfk_date_test_\(UUID().uuidString).txt")

        try "test".data(using: .utf8)!.write(to: file)
        defer { try? file.delete() }

        #expect(file.creationDate != nil)
        #expect(file.contentModificationDate != nil)
    }

    @Test("isAlias detects symbolic links")
    func isAliasDetectsSymlink() throws {
        let dir = URL(fileURLWithPath: NSTemporaryDirectory())
        let target = dir.appendingPathComponent("spfk_symlink_target_\(UUID().uuidString).txt")
        let link = dir.appendingPathComponent("spfk_symlink_\(UUID().uuidString).txt")

        try "target".data(using: .utf8)!.write(to: target)
        defer { try? target.delete() }

        try FileManager.default.createSymbolicLink(at: link, withDestinationURL: target)
        defer { try? link.delete() }

        #expect(link.isAlias)
        #expect(!target.isAlias)
    }
}
