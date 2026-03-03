import Foundation
@testable import SPFKBase
import Testing

@Suite("URL Extensions")
struct URLTests {
    // MARK: - Existence and readability

    @Test("exists returns true for real path")
    func exists() {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
        #expect(url.exists)
    }

    @Test("exists returns false for bogus path")
    func existsFalse() {
        let url = URL(fileURLWithPath: "/nonexistent_path_\(UUID().uuidString)")
        #expect(!url.exists)
    }

    @Test("isReadable for temp directory")
    func isReadable() {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
        #expect(url.isReadable)
    }

    // MARK: - Directory creation and deletion

    @Test("createDirectory and delete")
    func createAndDelete() throws {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("spfk_test_\(UUID().uuidString)")

        try url.createDirectory()
        #expect(url.exists)
        #expect(url.isDirectory)

        try url.delete()
        #expect(!url.exists)
    }

    // MARK: - isRemote

    @Test("isRemote for http URLs")
    func isRemote() {
        #expect(URL(string: "https://example.com")!.isRemote)
        #expect(URL(string: "http://example.com")!.isRemote)
        #expect(!URL(fileURLWithPath: "/tmp").isRemote)
    }

    // MARK: - contains(path:)

    @Test("contains path checks substring")
    func containsPath() {
        let url = URL(fileURLWithPath: "/Users/test/Documents/file.txt")
        #expect(url.contains(path: "Documents"))
        #expect(url.contains(path: "/Users/test/Documents/file.txt"))
        #expect(!url.contains(path: "Desktop"))
    }

    // MARK: - fileURLWithPathResolvingHome

    @Test("resolves tilde in path")
    func resolveTilde() {
        let url = URL(fileURLWithPathResolvingHome: "~/Documents")
        #expect(!url.path.contains("~"))
        #expect(url.path.contains(NSHomeDirectory()))
    }

    // MARK: - fileOrNetworkURLWithPath

    @Test("detects http vs file paths")
    func fileOrNetwork() {
        let httpURL = URL(fileOrNetworkURLWithPath: "https://example.com")
        #expect(httpURL?.scheme == "https")

        let fileURL = URL(fileOrNetworkURLWithPath: "/tmp/file.txt")
        #expect(fileURL?.isFileURL == true)
    }

    // MARK: - sortedByFileName

    @Test("URLs sort by filename")
    func sortedByFileName() {
        let urls = [
            URL(fileURLWithPath: "/tmp/c.txt"),
            URL(fileURLWithPath: "/tmp/a.txt"),
            URL(fileURLWithPath: "/tmp/b.txt"),
        ]
        let sorted = urls.sortedByFileName()
        #expect(sorted.map(\.lastPathComponent) == ["a.txt", "b.txt", "c.txt"])
    }

    // MARK: - File size

    @Test("fileSize returns value for real file")
    func fileSize() throws {
        let tmp = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("spfk_size_test_\(UUID().uuidString).txt")

        try "hello".data(using: .utf8)!.write(to: tmp)
        defer { try? tmp.delete() }

        let size = tmp.fileSize
        #expect(size != nil)
        #expect(size! > 0)
    }
}
