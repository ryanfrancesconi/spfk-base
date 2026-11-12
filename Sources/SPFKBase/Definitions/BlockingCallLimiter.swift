// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation

/// Admits a bounded number of blocking framework calls at once, process-wide.
///
/// For a synchronous framework call that blocks its thread on work needing a cooperative thread of its
/// own: with every cooperative thread held in such a call, whichever call each is in, none finishes. On 10
/// active cores, ten concurrent calls hung with none complete, and nine finished. Every such call shares
/// `shared`, since a count per call site does not bound the sum. This is the hard bound; a batch's own
/// width is a throughput setting and may be lower.
public actor BlockingCallLimiter {
    public static let shared = BlockingCallLimiter(width: max(1, ProcessInfo.processInfo.activeProcessorCount - 2))

    public let width: Int
    private var running = 0
    private var waiters: [CheckedContinuation<Void, Never>] = []

    public init(width: Int) {
        self.width = max(1, width)
    }

    /// Runs `body` on the caller's thread once a slot is free. `body` is synchronous, so it cannot wait
    /// on a second slot while holding one.
    public nonisolated func run<T>(_ body: () throws -> T) async rethrows -> T {
        await acquire()

        do {
            let result = try body()
            await release()
            return result
        } catch {
            await release()
            throw error
        }
    }

    private func acquire() async {
        guard running >= width else {
            running += 1
            return
        }

        await withCheckedContinuation { waiters.append($0) }
    }

    /// Hands the slot straight to the oldest waiter, so `running` counts it without a gap.
    private func release() {
        if waiters.isEmpty {
            running -= 1
        } else {
            waiters.removeFirst().resume()
        }
    }
}
