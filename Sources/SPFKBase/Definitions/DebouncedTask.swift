// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation

/// Cancels any previously scheduled operation before starting a new one,
/// optionally after a delay. Useful for coalescing rapid user actions
/// (e.g., debounced search, delayed load after selection change).
@MainActor
public final class DebouncedTask {
    private var task: Task<Void, Never>?
    private var currentID: UInt64 = 0

    public var isRunning: Bool { task != nil && task?.isCancelled == false }

    public init() {}

    /// Cancel the previous operation (if any) and schedule a new one.
    /// A non-zero `delay` inserts a sleep before execution; if `run`
    /// is called again during the sleep the earlier operation is cancelled.
    public func run(delay: TimeInterval = 0, operation: @escaping @Sendable () async throws -> Void) {
        let effectiveDelay = task != nil ? delay : 0
        task?.cancel()
        currentID &+= 1
        let myID = currentID
        task = Task { [weak self] in
            defer {
                // Only clear the task reference if no newer task has been scheduled.
                // Without this guard a cancelled task's cleanup would wipe the reference
                // to its successor, making it untrackable and uncancellable.
                if self?.currentID == myID {
                    self?.task = nil
                }
            }
            do {
                if effectiveDelay > 0 {
                    try await Task.sleep(seconds: effectiveDelay)
                }
                try Task.checkCancellation()
                try await operation()
            } catch is CancellationError {
                // expected when superseded by a later invocation
            } catch {
                Log.error(error)
            }
        }
    }

    public func cancel() {
        task?.cancel()
        task = nil
    }
}
