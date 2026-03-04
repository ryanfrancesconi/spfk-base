import Foundation
@testable import SPFKBase
import Testing

@Suite("URL Directory Extensions")
struct URLDirectoryTests {
    @Test("isEmpty on empty directory")
    func isEmptyDirectory() throws {
        let dir = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("spfk_empty_test_\(UUID().uuidString)")

        try dir.createDirectory()
        defer { try? dir.delete() }

        #expect(dir.isEmpty)
    }

    @Test("directoryContents lists files")
    func directoryContents() throws {
        let dir = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("spfk_contents_test_\(UUID().uuidString)")

        try dir.createDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }

        let file = dir.appendingPathComponent("test.txt")
        try "content".data(using: .utf8)!.write(to: file)

        let contents = dir.directoryContents
        #expect(contents != nil)
        #expect(contents!.count == 1)
        #expect(contents!.first?.lastPathComponent == "test.txt")
    }

    @Test("listDirectory throws for nonexistent path")
    func listDirectoryThrows() {
        let dir = URL(fileURLWithPath: "/nonexistent_\(UUID().uuidString)")
        #expect(throws: (any Error).self) {
            try dir.listDirectory()
        }
    }

    @Test("queryString joins items")
    func queryString() {
        let items = [
            URLQueryItem(name: "key", value: "value"),
            URLQueryItem(name: "foo", value: "bar"),
        ]
        let result = URL.queryString(items: items)
        #expect(result == "key=value&foo=bar")
    }

    @Test("queryString handles nil values")
    func queryStringNilValue() {
        let items = [URLQueryItem(name: "key", value: nil)]
        let result = URL.queryString(items: items)
        #expect(result == "key=")
    }

    @Test("queryString percent-encodes special characters")
    func queryStringEncoding() {
        let items = [URLQueryItem(name: "q", value: "hello world&more=yes")]
        let result = URL.queryString(items: items)
        // Spaces and & should be encoded
        #expect(!result.contains(" "))
        #expect(result.hasPrefix("q="))
    }
}
