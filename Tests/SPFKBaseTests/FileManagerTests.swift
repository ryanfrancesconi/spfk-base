import Foundation
@testable import SPFKBase
import Testing

@Suite("FileManager Extensions")
struct FileManagerTests {
    @Test("modificationDateForFileAtPath returns date for real file")
    func modificationDate() throws {
        let path = NSTemporaryDirectory() + "spfk_fm_test_\(UUID().uuidString).txt"
        let url = URL(fileURLWithPath: path)

        try "test".data(using: .utf8)!.write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }

        let date = FileManager.default.modificationDateForFileAtPath(path: path)
        #expect(date != nil)
    }

    @Test("creationDateForFileAtPath returns date for real file")
    func creationDate() throws {
        let path = NSTemporaryDirectory() + "spfk_fm_create_\(UUID().uuidString).txt"
        let url = URL(fileURLWithPath: path)

        try "test".data(using: .utf8)!.write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }

        let date = FileManager.default.creationDateForFileAtPath(path: path)
        #expect(date != nil)
    }

    @Test("modificationDate returns nil for nonexistent file")
    func modificationDateNonexistent() {
        let date = FileManager.default.modificationDateForFileAtPath(path: "/nonexistent_\(UUID().uuidString)")
        #expect(date == nil)
    }

    @Test("isInTrash returns false for temp file")
    func isInTrash() throws {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("spfk_trash_test_\(UUID().uuidString).txt")

        try "test".data(using: .utf8)!.write(to: url)
        defer { try? url.delete() }

        #expect(!FileManager.default.isInTrash(url))
    }
}
