// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation

/// Cooperative stop flag for a file-parsing pass, checked between files rather than cancelling the
/// task running them.
///
/// **Why not `Task.cancel()`:** cancelling tears down whatever AVFoundation property loads are in
/// flight. `AVAsset.load`/`loadTracks` are built on checked throwing continuations, and cancelling
/// mid-load leaks them -- "SWIFT TASK CONTINUATION MISUSE: ... leaked its continuation without
/// resuming it", one per in-flight file, observed on a real import. A leaked continuation is a task
/// suspended forever. Stopping cooperatively costs at most one batch of already-started files and
/// leaves no torn-down loads behind.
///
/// Both products' parsers read video (`VideoTrackReader` in TorchTag's, an
/// `AudioPlaylistElement` parse reaching `MetaAudioFileDescription.loadVideoTrack()` in
/// ShadowTag's), so both are exposed to the same leak and share this.
///
/// Lock-guarded rather than an actor so ``stop()`` takes effect *synchronously*. As an actor the
/// cancellation handler had to hop through a `Task` to set it, and a folder small enough to finish
/// inside that hop imported anyway despite the user having pressed Cancel.
public final class ParseStopSignal: @unchecked Sendable {
    private let lock = NSLock()
    private var stopped = false

    public init() {}

    public var isStopped: Bool {
        lock.withLock { stopped }
    }

    public func stop() {
        lock.withLock { stopped = true }
    }
}
