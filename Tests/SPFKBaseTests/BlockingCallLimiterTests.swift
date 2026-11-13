// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import Testing

@testable import SPFKBase

@Suite("BlockingCallLimiter")
struct BlockingCallLimiterTests {
    private final class Occupancy: @unchecked Sendable {
        private let lock = NSLock()
        private var current = 0
        private(set) var peak = 0

        func enter() { lock.withLock { current += 1; peak = max(peak, current) } }
        func leave() { lock.withLock { current -= 1 } }
    }

    /// A body that holds its slot until the test lets it go.
    private final class Gate: @unchecked Sendable {
        private let lock = NSLock()
        private var _entered = false
        private var _released = false
        private var _ran = false

        var entered: Bool { lock.withLock { _entered } }
        var ran: Bool { lock.withLock { _ran } }

        func hold() {
            lock.withLock { _entered = true }
            while !lock.withLock({ _released }) {
                Thread.sleep(forTimeInterval: 0.005)
            }
        }

        func release() { lock.withLock { _released = true } }
        func markRan() { lock.withLock { _ran = true } }
    }

    @Test func noMoreThanTheWidthRunAtOnce() async {
        let limiter = BlockingCallLimiter(width: 2)
        let occupancy = Occupancy()

        await withTaskGroup(of: Void.self) { group in
            for _ in 0 ..< 8 {
                group.addTask {
                    await limiter.run {
                        occupancy.enter()
                        Thread.sleep(forTimeInterval: 0.02)
                        occupancy.leave()
                    }
                }
            }
        }

        #expect(occupancy.peak == 2)
    }

    @Test func aThrowingBodyReleasesItsSlot() async {
        let limiter = BlockingCallLimiter(width: 1)
        struct Failure: Error {}

        await #expect(throws: Failure.self) {
            try await limiter.run { throw Failure() }
        }

        #expect(await limiter.run { true })
    }

    /// A task cancelled while queued for a slot gets one, and a body checking on entry throws there.
    @Test func aBodyCheckingCancellationThrowsForATaskCancelledWhileQueued() async throws {
        let limiter = BlockingCallLimiter(width: 1)
        let gate = Gate()

        let holder = Task { await limiter.run { gate.hold() } }

        while !gate.entered {
            try await Task.sleep(for: .milliseconds(5))
        }

        let queued = Task {
            try await limiter.run {
                try Task.checkCancellation()
                gate.markRan()
            }
        }

        try await Task.sleep(for: .milliseconds(50))
        queued.cancel()
        gate.release()
        await holder.value

        await #expect(throws: CancellationError.self) { try await queued.value }
        #expect(!gate.ran)
        #expect(await limiter.run { true })
    }

    // MARK: - BlockingCallAdmission

    /// Past the limiter's width, which only bodies that take no slot can exceed.
    @Test func ownThreadBodiesAllRunAtOnce() async throws {
        let count = BlockingCallLimiter.shared.width + 4
        let occupancy = Occupancy()
        let gate = Gate()

        try await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0 ..< count {
                group.addTask {
                    try await BlockingCallAdmission.ownThread.admit {
                        occupancy.enter()
                        gate.hold()
                        occupancy.leave()
                    }
                }
            }

            while occupancy.peak < count {
                try await Task.sleep(for: .milliseconds(5))
            }

            gate.release()
            try await group.waitForAll()
        }

        #expect(occupancy.peak == count)
    }

    @Test func anOwnThreadBodyRethrowsAndReturns() async throws {
        struct Failure: Error {}

        await #expect(throws: Failure.self) {
            try await BlockingCallAdmission.ownThread.admit { throw Failure() }
        }

        #expect(try await BlockingCallAdmission.ownThread.admit { 7 } == 7)
    }

    @Test func limitedBodiesStayWithinTheSharedWidth() async throws {
        let width = BlockingCallLimiter.shared.width
        let occupancy = Occupancy()

        try await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0 ..< width + 4 {
                group.addTask {
                    try await BlockingCallAdmission.limited.admit {
                        occupancy.enter()
                        Thread.sleep(forTimeInterval: 0.02)
                        occupancy.leave()
                    }
                }
            }

            try await group.waitForAll()
        }

        #expect(occupancy.peak <= width)
    }
}
