// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import CoreGraphics
import Foundation

/// Abstract progress reporting protocol for file-parsing operations.
///
/// Describes three lifecycle events — start, per-item update, and finish — without
/// any coupling to a specific UI presentation. Callers implement this protocol to
/// receive progress and optionally wire cancellation.
///
/// `ModalProgressAccess` conformers automatically satisfy this protocol via the bridging
/// extension in `SPFKUI`, so a delegate that inherits both gets it for free.
@MainActor
public protocol ParseProgressAccess: AnyObject, Sendable {
    /// Called once before scanning begins.
    /// - Parameters:
    ///   - itemCount: Number of root URLs being scanned (pre-directory expansion).
    ///   - cancellationHandler: Invoke this closure to cancel the in-progress parse.
    func parseProgressStart(itemCount: Int, cancellationHandler: (() -> Void)?)

    /// Called during the folder scan, before any file is parsed.
    func parseProgressScanning(foundCount: Int)

    /// Called once per successfully parsed file.
    func parseProgressUpdate(filename: String, progress: UnitInterval, cgImage: CGImage?)

    /// Called when parsing completes or throws, including on cancellation.
    func parseProgressFinish()

    /// Called by the importer after the parse, while `count` parsed files go into the store and
    /// the table.
    func parseProgressAdding(count: Int)
}

extension ParseProgressAccess {
    public func parseProgressScanning(foundCount: Int) {}
    public func parseProgressAdding(count: Int) {}
}
