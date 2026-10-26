// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

#if os(macOS)
    import Foundation
    import SPFKBase
    import Testing

    struct ProcessRunnerTests {
        private func sh(_ script: String, timeout: Duration = .seconds(10)) async throws -> ProcessOutput {
            try await ProcessRunner.run(URL(fileURLWithPath: "/bin/sh"), arguments: ["-c", script], timeout: timeout)
        }

        @Test func capturesBothStreamsAndTheStatus() async throws {
            let output = try await sh("echo out; echo err >&2; exit 3")
            #expect(output.stdout == "out\n")
            #expect(output.stderr == "err\n")
            #expect(output.status == 3)
            #expect(output.reason == .exit)
            #expect(!output.timedOut)
        }

        /// A shell reports this as exit 139; the runner as the signal itself.
        @Test func signalIsReportedAsTheSignal() async throws {
            let output = try await sh("kill -SEGV $$")
            #expect(output.reason == .uncaughtSignal)
            #expect(output.status == 11)
        }

        /// Far past a pipe buffer on both streams, which a pipe read one after the other deadlocks on.
        @Test func largeOutputOnBothStreamsCompletes() async throws {
            let output = try await sh("head -c 300000 /dev/zero | tr '\\0' a >&2; head -c 300000 /dev/zero | tr '\\0' b")
            #expect(output.stdout.count == 300_000)
            #expect(output.stderr.count == 300_000)
        }

        @Test func deadlineTerminatesAndWaitsForTheExit() async throws {
            let start = ContinuousClock.now
            let output = try await sh("sleep 20", timeout: .milliseconds(300))
            #expect(output.timedOut)
            #expect(output.reason == .uncaughtSignal)
            #expect(ContinuousClock.now - start < .seconds(10))
        }

        @Test func cancellationTerminates() async throws {
            let start = ContinuousClock.now
            let task = Task { try await sh("sleep 20") }
            try await Task.sleep(for: .milliseconds(300))
            task.cancel()
            let output = try await task.value
            #expect(output.reason == .uncaughtSignal)
            #expect(!output.timedOut)
            #expect(ContinuousClock.now - start < .seconds(10))
        }

        @Test func missingExecutableThrows() async {
            await #expect(throws: (any Error).self) {
                try await ProcessRunner.run(URL(fileURLWithPath: "/nonexistent/fuscript"), arguments: [], timeout: .seconds(1))
            }
        }

        /// SIGTERM alone would wait on this child for as long as it chooses to run.
        @Test func childIgnoringTerminateIsKilledAfterTheGracePeriod() async throws {
            let start = ContinuousClock.now
            let output = try await sh("trap '' TERM; sleep 20", timeout: .milliseconds(300))
            #expect(output.timedOut)
            #expect(output.reason == .uncaughtSignal)
            #expect(output.status == SIGKILL)
            #expect(ContinuousClock.now - start < .milliseconds(300) + ProcessRunner.gracePeriod + .seconds(3))
        }

        /// Terminating only the direct child would leave this grandchild running on its own.
        @Test func deadlineEndsTheGrandchildrenToo() async throws {
            let output = try await sh("trap '' TERM; sleep 20 & echo $!; wait", timeout: .milliseconds(300))
            #expect(output.timedOut)
            let pid = try #require(pid_t(output.stdout.trimmingCharacters(in: .whitespacesAndNewlines)))
            try await expectExited(pid)
        }

        /// The run ends at the parent's exit even though a detached grandchild still holds stdout.
        @Test func detachedGrandchildDoesNotHoldTheRunOpen() async throws {
            let start = ContinuousClock.now
            let output = try await sh("(sleep 20 &); echo done")
            #expect(output.stdout == "done\n")
            #expect(output.reason == .exit)
            #expect(output.status == 0)
            #expect(!output.timedOut)
            #expect(ContinuousClock.now - start < .seconds(5))
        }

        @Test func outputAtTheLimitIsKept() async throws {
            let output = try await sh("head -c \(ProcessRunner.outputLimit) /dev/zero")
            #expect(output.stdout.utf8.count == ProcessRunner.outputLimit)
        }

        @Test func outputPastTheLimitThrows() async {
            await #expect(throws: ProcessRunner.OutputLimitExceeded.self) {
                try await sh("head -c \(ProcessRunner.outputLimit + 1) /dev/zero >&2")
            }
        }

        /// The throw does not leave the child running on after the run has given up on it.
        @Test func outputPastTheLimitEndsTheProcess() async throws {
            let pidURL = FileManager.default.temporaryDirectory.appendingPathComponent("spfk-base-\(UUID().uuidString).pid")
            defer { try? FileManager.default.removeItem(at: pidURL) }

            await #expect(throws: ProcessRunner.OutputLimitExceeded.self) {
                try await sh("echo $$ > '\(pidURL.path)'; head -c \(ProcessRunner.outputLimit + 1) /dev/zero; sleep 20")
            }
            let text = try String(contentsOf: pidURL, encoding: .utf8)
            let pid = try #require(pid_t(text.trimmingCharacters(in: .whitespacesAndNewlines)))
            try await expectExited(pid)
        }

        private func expectExited(_ pid: pid_t) async throws {
            let deadline = ContinuousClock.now + ProcessRunner.gracePeriod + .seconds(3)
            while kill(pid, 0) == 0, ContinuousClock.now < deadline {
                try await Task.sleep(for: .milliseconds(50))
            }
            #expect(kill(pid, 0) != 0, "process \(pid) is still running")
        }

        @Test func cancellationBeforeLaunchReturnsPromptly() async throws {
            let start = ContinuousClock.now
            let task = Task {
                withUnsafeCurrentTask { $0?.cancel() }
                return try await sh("sleep 20")
            }
            let output = try await task.value
            #expect(!output.timedOut)
            #expect(ContinuousClock.now - start < .seconds(5))
        }

        /// `cat` reading an open stdin would wait for the deadline.
        @Test func stdinIsClosed() async throws {
            let output = try await ProcessRunner.run(URL(fileURLWithPath: "/bin/cat"), arguments: [], timeout: .seconds(5))
            #expect(output.status == 0)
            #expect(output.stdout.isEmpty)
            #expect(!output.timedOut)
        }
    }
#endif
