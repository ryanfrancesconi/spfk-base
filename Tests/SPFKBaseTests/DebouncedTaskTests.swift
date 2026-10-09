// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import os
import Testing

@testable import SPFKBase

@Suite("DebouncedTask")
@MainActor
struct DebouncedTaskTests {
    @Test("immediate execution with zero delay")
    func immediateExecution() async throws {
        let task = DebouncedTask()

        try await confirmation { executed in
            task.run {
                executed()
            }

            // Give the task a moment to complete
            try await Task.sleep(seconds: 0.05)
        }
    }

    @Test("later invocation cancels earlier")
    func laterCancelsEarlier() async throws {
        let task = DebouncedTask()
        let firstCalled = OSAllocatedUnfairLock(initialState: false)

        try await confirmation("second called") { secondExecuted in
            task.run(delay: 0.2) {
                firstCalled.withLock { $0 = true }
            }

            // Immediately supersede with a second call
            task.run(delay: 0.1) {
                secondExecuted()
            }

            try await Task.sleep(seconds: 0.5)
        }

        #expect(!firstCalled.withLock { $0 })
    }

    @Test("cancel prevents execution")
    func cancelPreventsExecution() async throws {
        let task = DebouncedTask()

        try await confirmation(expectedCount: 0) { executed in
            task.run(delay: 0.1) {
                executed()
            }

            task.cancel()

            try await Task.sleep(seconds: 0.2)
        }
    }

    @Test("isRunning reflects task state")
    func isRunningState() async throws {
        let task = DebouncedTask()
        #expect(!task.isRunning)

        task.run(delay: 0.1) {
            // no-op
        }

        #expect(task.isRunning)

        task.cancel()
        #expect(!task.isRunning)
    }

    @Test("task clears itself after completion")
    func autoClears() async throws {
        let task = DebouncedTask()

        task.run {
            // immediate completion
        }

        try await Task.sleep(seconds: 0.05)
        #expect(!task.isRunning)
    }

    @Test("non-cancellation errors are handled gracefully")
    func errorHandling() async throws {
        let task = DebouncedTask()

        struct TestError: Error {}

        task.run {
            throw TestError()
        }

        // Should not crash; error is logged
        try await Task.sleep(seconds: 0.05)
        #expect(!task.isRunning)
    }
}

// MARK: - Superseded operations

/// An operation that cannot be stopped once inside it, as a synchronous read cannot.
private final class Latch: Sendable {
    private let state = OSAllocatedUnfairLock<(isOpen: Bool, waiters: [CheckedContinuation<Void, Never>])>(
        initialState: (false, [])
    )

    /// Ignores cancellation.
    func wait() async {
        await withCheckedContinuation { continuation in
            let isOpen = state.withLock { state -> Bool in
                if state.isOpen { return true }
                state.waiters.append(continuation)
                return false
            }
            if isOpen { continuation.resume() }
        }
    }

    func open() {
        let waiters = state.withLock { state in
            state.isOpen = true
            defer { state.waiters = [] }
            return state.waiters
        }
        waiters.forEach { $0.resume() }
    }
}

private final class EventLog: Sendable {
    private let events = OSAllocatedUnfairLock<[String]>(initialState: [])

    func append(_ event: String) { events.withLock { $0.append(event) } }
    var all: [String] { events.withLock { $0 } }
}

@Suite("DebouncedTask superseding")
@MainActor
struct DebouncedTaskSupersedingTests {
    /// Long enough for an operation that was not held back to have started.
    private let settle: TimeInterval = 0.1

    private func poll(timeout: TimeInterval = 5, until condition: () -> Bool) async throws {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() {
            try #require(Date() < deadline, "timed out")
            try await Task.sleep(seconds: 0.005)
        }
    }

    /// Schedules an operation that logs "A start", blocks on `latch` and logs "A end".
    private func runBlocking(_ task: DebouncedTask, latch: Latch, log: EventLog) async throws {
        task.run {
            log.append("A start")
            await latch.wait()
            log.append("A end")
        }
        try await poll { log.all.contains("A start") }
    }

    @Test("a successor starts only once its superseded predecessor has ended")
    func successorWaitsForPredecessor() async throws {
        let task = DebouncedTask()
        let latch = Latch()
        let log = EventLog()

        try await runBlocking(task, latch: latch, log: log)

        task.run { log.append("B start") }

        try await Task.sleep(seconds: settle)
        #expect(log.all == ["A start"])

        latch.open()
        try await poll { log.all.contains("B start") }
        #expect(log.all == ["A start", "A end", "B start"])
    }

    @Test("ordering holds through a successor superseded during its delay")
    func orderingSurvivesASupersededDelay() async throws {
        let task = DebouncedTask()
        let latch = Latch()
        let log = EventLog()

        try await runBlocking(task, latch: latch, log: log)

        task.run(delay: 0.2) { log.append("B start") }
        task.run { log.append("C start") }

        try await Task.sleep(seconds: settle)
        #expect(log.all == ["A start"])

        latch.open()
        try await poll { log.all.contains("C start") }
        #expect(log.all == ["A start", "A end", "C start"])
    }

    @Test("an operation scheduled after cancel() waits for the cancelled one")
    func runAfterCancelWaits() async throws {
        let task = DebouncedTask()
        let latch = Latch()
        let log = EventLog()

        try await runBlocking(task, latch: latch, log: log)

        task.cancel()
        task.run { log.append("B start") }

        try await Task.sleep(seconds: settle)
        #expect(log.all == ["A start"])

        latch.open()
        try await poll { log.all.contains("B start") }
        #expect(log.all == ["A start", "A end", "B start"])
    }

    @Test("finish() waits for every superseded operation, not only the latest")
    func finishWaitsForTheChain() async throws {
        let task = DebouncedTask()
        let latch = Latch()
        let log = EventLog()

        try await runBlocking(task, latch: latch, log: log)
        task.run { log.append("B start") }

        let finishing = Task { @MainActor in
            await task.finish()
            log.append("finished")
        }

        try await Task.sleep(seconds: settle)
        #expect(!log.all.contains("finished"))

        latch.open()
        await finishing.value
        #expect(log.all.prefix(2) == ["A start", "A end"])
        #expect(log.all.last == "finished")
        #expect(!task.isRunning)
    }
}
