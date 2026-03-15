// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation

/// Cancels any previously scheduled operation before starting a new one,
/// optionally after a delay. Useful for coalescing rapid user actions
/// (e.g., debounced search, delayed load after selection change).
@MainActor
public final class DebouncedTask {
    private var task: Task<Void, Never>?

    public var isRunning: Bool { task != nil && task?.isCancelled == false }

    public init() {}

    /// Cancel the previous operation (if any) and schedule a new one.
    /// A non-zero `delay` inserts a sleep before execution; if `run`
    /// is called again during the sleep the earlier operation is cancelled.
    public func run(delay: TimeInterval = 0, operation: @escaping @Sendable () async throws -> Void) {
        task?.cancel()
        task = Task { [weak self] in
            do {
                if delay > 0 {
                    try await Task.sleep(seconds: delay)
                }
                try Task.checkCancellation()
                try await operation()
            } catch is CancellationError {
                // expected when superseded by a later invocation
            } catch {
                Log.error(error)
            }
            self?.task = nil
        }
    }

    public func cancel() {
        task?.cancel()
        task = nil
    }
}
