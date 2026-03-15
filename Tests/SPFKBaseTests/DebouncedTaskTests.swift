// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
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

        try await confirmation("first not called", expectedCount: 0) { firstExecuted in
            try await confirmation("second called") { secondExecuted in
                task.run(delay: 0.1) {
                    firstExecuted()
                }

                // Immediately supersede with a second call
                task.run(delay: 0.05) {
                    secondExecuted()
                }

                try await Task.sleep(seconds: 0.2)
            }
        }
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
