// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation

/// How a synchronous framework call that blocks its thread on other threads' work is kept from
/// occupying every cooperative thread.
public enum BlockingCallAdmission: Sendable {
    /// Takes a ``BlockingCallLimiter/shared`` slot, queueing behind other blocking calls. For
    /// throughput work.
    case limited

    /// Runs on a thread of its own, so it never queues and nothing bounds it. For a call that must
    /// not wait behind other work, such as a playback feed.
    case ownThread

    /// Runs `body` under this admission while the caller suspends.
    public func admit<T: Sendable>(_ body: @escaping @Sendable () throws -> T) async throws -> T {
        switch self {
        case .limited:
            try await BlockingCallLimiter.shared.run(body)

        case .ownThread:
            try await withCheckedThrowingContinuation { continuation in
                Thread.detachNewThread {
                    continuation.resume(with: Result(catching: body))
                }
            }
        }
    }
}
