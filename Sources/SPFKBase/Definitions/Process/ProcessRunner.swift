// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

#if os(macOS)
    import Foundation
    import Subprocess
    import System

    /// Runs a process to its exit without blocking a thread, collecting stdout and stderr separately.
    public enum ProcessRunner {
        /// Bytes collected from each stream before a run throws ``OutputLimitExceeded``.
        public static let outputLimit = 8 * 1024 * 1024

        /// How long a terminated process has to exit after SIGTERM before its process group is killed.
        public static let gracePeriod: Duration = .seconds(2)

        /// A stream passed ``outputLimit``. Thrown rather than truncated, because truncation drops
        /// the end of the output, which is where a verdict is usually printed.
        public struct OutputLimitExceeded: Error, Sendable {
            public let limit: Int
        }

        /// Returns once the process has exited. The deadline and a cancellation of the calling task
        /// both end it, SIGTERM then SIGKILL to its whole process group, and still return its status.
        /// Throws when it cannot be started, or on ``OutputLimitExceeded``.
        public static func run(_ executable: URL, arguments: [String], timeout: Duration) async throws -> ProcessOutput {
            try await withThrowingTaskGroup(of: Finished.self) { group in
                group.addTask { try await collect(executable, arguments: arguments) }
                group.addTask {
                    do { try await Task.sleep(for: timeout) } catch { return .deadlineCancelled }
                    return .deadlinePassed
                }

                var timedOut = false
                while let finished = try await group.next() {
                    switch finished {
                    case .deadlinePassed:
                        timedOut = true
                        group.cancelAll()
                    case .deadlineCancelled:
                        break
                    case let .exited(status, reason, stdout, stderr):
                        group.cancelAll()
                        return ProcessOutput(stdout: stdout, stderr: stderr, status: status, reason: reason, timedOut: timedOut)
                    }
                }
                // The run child always returns or throws before the group drains.
                throw CancellationError()
            }
        }

        private enum Finished: Sendable {
            case exited(Int32, ProcessOutput.TerminationReason, stdout: String, stderr: String)
            case deadlinePassed
            case deadlineCancelled
        }

        private static func collect(_ executable: URL, arguments: [String]) async throws -> Finished {
            // Its own session, so the teardown also ends whatever it started rather than orphaning it.
            var options = PlatformOptions()
            options.createSession = true
            options.teardownSequence = [.gracefulShutDown(toProcessGroup: true, allowedDurationToNextStep: gracePeriod)]

            do {
                let result = try await Subprocess.run(
                    .path(FilePath(executable.path)),
                    arguments: Arguments(arguments),
                    platformOptions: options,
                    input: .none,
                    output: .string(limit: outputLimit),
                    error: .string(limit: outputLimit)
                )
                switch result.terminationStatus {
                case let .exited(code):
                    return .exited(code, .exit, stdout: result.standardOutput, stderr: result.standardError)
                case let .signaled(signal):
                    return .exited(signal, .uncaughtSignal, stdout: result.standardOutput, stderr: result.standardError)
                }
            } catch let error as SubprocessError where error.code == .outputLimitExceeded {
                throw OutputLimitExceeded(limit: outputLimit)
            }
        }
    }
#endif
