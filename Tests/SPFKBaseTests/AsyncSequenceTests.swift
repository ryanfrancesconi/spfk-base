import Foundation
import Testing

@testable import SPFKBase

@Suite("AsyncSequence Extensions")
struct AsyncSequenceTests {
    @Test("toArray collects all elements")
    func toArray() async throws {
        let stream = AsyncStream<Int> { continuation in
            for i in 1 ... 5 {
                continuation.yield(i)
            }
            continuation.finish()
        }

        let result = await stream.toArray()
        #expect(result == [1, 2, 3, 4, 5])
    }

    @Test("toArray on empty stream returns empty array")
    func toArrayEmpty() async throws {
        let stream = AsyncStream<Int> { continuation in
            continuation.finish()
        }

        let result = await stream.toArray()
        #expect(result.isEmpty)
    }
}
