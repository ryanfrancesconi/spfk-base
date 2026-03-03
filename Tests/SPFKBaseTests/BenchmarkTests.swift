import Foundation
@testable import SPFKBase
import Testing

@Suite("Benchmark")
struct BenchmarkTests {
    @Test("start and stop records elapsed time")
    func startStop() async throws {
        let bench = Benchmark()
        bench.start(label: "test")
        #expect(bench.isStarted)
        #expect(bench.label == "test")

        try await Task.sleep(seconds: 0.05)

        let elapsed = bench.stop()
        #expect(!bench.isStarted)
        #expect(elapsed > 0)
        #expect(bench.endScanTime > 0)
    }

    @Test("init with label auto-starts")
    func initWithLabel() {
        let bench = Benchmark(label: "auto")
        #expect(bench.isStarted)
        #expect(bench.label == "auto")
    }

    @Test("stop when not started returns -1")
    func stopWhenNotStarted() {
        let bench = Benchmark()
        let result = bench.stop()
        #expect(result == -1)
    }

    @Test("double start stops first then restarts")
    func doubleStart() {
        let bench = Benchmark(label: "first")
        #expect(bench.isStarted)

        bench.start(label: "second")
        #expect(bench.isStarted)
        #expect(bench.label == "second")
    }
}
