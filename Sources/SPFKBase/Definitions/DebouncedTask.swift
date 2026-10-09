// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation

/// Runs one operation at a time, optionally after a delay, for coalescing rapid user actions
/// (a debounced search, a delayed load after a selection change).
///
/// A new operation cancels the one before it and starts only once that one has ended, so
/// operations never overlap. Cancellation is observed only at the operation's own checks, so one
/// written to stop early should check `Task.isCancelled` after each suspension before it writes
/// anything.
@MainActor
public final class DebouncedTask {
    private var task: Task<Void, Never>?
    private var currentID: UInt64 = 0

    public var isRunning: Bool { task != nil && task?.isCancelled == false }

    public init() {}

    /// Cancel the previous operation (if any) and schedule a new one.
    /// A non-zero `delay` inserts a sleep before execution; if `run`
    /// is called again during the sleep the earlier operation is cancelled.
    /// The delay runs alongside the predecessor's wind-down rather than after it.
    public func run(delay: TimeInterval = 0, operation: @escaping @Sendable () async throws -> Void) {
        let predecessor = task
        let effectiveDelay = predecessor != nil ? delay : 0
        predecessor?.cancel()
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

            if effectiveDelay > 0 {
                // Returns early when superseded; the predecessor is still awaited below.
                try? await Task.sleep(seconds: effectiveDelay)
            }

            // Awaited even when cancelled, so each task ends after the one before it and awaiting
            // the latest awaits them all.
            await predecessor?.value

            do {
                try Task.checkCancellation()
                try await operation()
            } catch is CancellationError {
                // expected when superseded by a later invocation
            } catch {
                Log.error(error)
            }
        }
    }

    /// Cancels the scheduled operation without waiting for it. The handle is kept, so the next
    /// ``run(delay:operation:)`` still starts only once this one has ended.
    public func cancel() {
        task?.cancel()
    }

    /// Cancels the scheduled operation and waits for it, and every operation it superseded, to end.
    ///
    /// Anything reclaiming a resource the operation touches has to use this rather than
    /// ``cancel()``, since an operation already inside a synchronous read keeps running.
    public func finish() async {
        let inFlight = task
        let inFlightID = currentID
        inFlight?.cancel()
        await inFlight?.value

        // As in `run`'s defer: leave a task scheduled while this one was ending alone.
        if currentID == inFlightID {
            task = nil
        }
    }
}
