// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SPFKBase
import Testing

@Suite
final class ParseStopSignalTests {
    /// The whole reason this is lock-guarded rather than an actor: a cancellation handler sets it
    /// and the very next read has to see it. As an actor the handler had to hop through a `Task`,
    /// and a folder small enough to finish inside that hop imported anyway despite Cancel.
    @Test func stopIsVisibleImmediately() {
        let signal = ParseStopSignal()
        #expect(!signal.isStopped)

        signal.stop()

        #expect(signal.isStopped)
    }

    /// Parse workers check the flag concurrently while the handler sets it; once stopped it must
    /// never read back false, or a worker would start a load the user already cancelled.
    @Test func stopHoldsUnderConcurrentReads() async {
        let signal = ParseStopSignal()

        await withTaskGroup(of: Bool.self) { group in
            for _ in 0 ..< 8 {
                group.addTask { signal.isStopped }
            }
            group.addTask {
                signal.stop()
                return true
            }
            for await _ in group {}
        }

        #expect(signal.isStopped)

        // Still stopped after the fact -- no reader resets it.
        await withTaskGroup(of: Bool.self) { group in
            for _ in 0 ..< 8 {
                group.addTask { signal.isStopped }
            }
            for await observed in group {
                #expect(observed)
            }
        }
    }
}
