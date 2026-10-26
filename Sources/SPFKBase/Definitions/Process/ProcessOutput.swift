// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

#if os(macOS)
    import Foundation

    /// A finished process and what it wrote.
    public struct ProcessOutput: Sendable, Equatable {
        public enum TerminationReason: Sendable, Equatable {
            case exit
            case uncaughtSignal
        }

        public let stdout: String
        public let stderr: String
        /// The exit code, or the signal number when `reason` is `.uncaughtSignal`.
        public let status: Int32
        public let reason: TerminationReason
        /// The deadline passed and the process was terminated.
        public let timedOut: Bool

        public init(stdout: String, stderr: String, status: Int32, reason: TerminationReason, timedOut: Bool) {
            self.stdout = stdout
            self.stderr = stderr
            self.status = status
            self.reason = reason
            self.timedOut = timedOut
        }
    }
#endif
