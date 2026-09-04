// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation

/// Step timing for a path that gets measured over and over, left in the code rather than added and
/// stripped each time.
///
/// **The reason it is not `Log.debug`**: that is compiled out in release, and a load path has to be
/// measured in release or not at all — an unoptimized run distorts the shape of a comparison and not
/// only its scale. So this logs through `Log.default` and is gated at runtime instead.
///
/// **Off in a release build unless asked for**, by launching with `-SPFKTiming YES` (an argument in
/// the scheme's Run options, so turning it on costs no rebuild). On in a debug build, matching what
/// the launch-phase timing already did.
///
/// ```swift
/// var trace = PhaseTrace("LOAD")
/// ...
/// trace.mark("fetched \(album.storedElements.count)")
/// ```
///
/// Each mark reports the step just finished and the running total, so a line can be read on its own
/// or against the one before it.
public struct PhaseTrace {
    /// Asked for at launch, read once — neither source can change while the process runs.
    ///
    /// **Two spellings because Xcode's scheme has two fields and they reach different places.**
    /// "Arguments Passed On Launch" (`-SPFKTiming YES`) lands in `UserDefaults`' argument domain;
    /// "Environment Variables" (`SPFKTiming=1`) does not, and is what the benches already use.
    private static let isRequested: Bool = {
        if UserDefaults.standard.bool(forKey: "SPFKTiming") { return true }

        guard let value = ProcessInfo.processInfo.environment["SPFKTiming"] else { return false }

        return !["", "0", "NO", "no", "false", "FALSE"].contains(value)
    }()

    /// **`Log.buildConfig` is read every time rather than folded into the line above.** The app
    /// assigns it during launch, so a `static let` combining the two latches whichever value was
    /// current when something first happened to ask — which is an ordering nobody controls.
    public static var isEnabled: Bool { isRequested || Log.buildConfig != .release }

    private let label: String
    private let start: TimeInterval
    private var previous: TimeInterval

    public init(_ label: String) {
        self.label = label
        start = ProcessInfo.processInfo.systemUptime
        previous = start
    }

    /// Seconds since the trace began, whether or not anything is being logged.
    public var elapsed: TimeInterval { ProcessInfo.processInfo.systemUptime - start }

    public mutating func mark(
        _ step: @autoclosure () -> String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let now = ProcessInfo.processInfo.systemUptime
        defer { previous = now }

        guard Self.isEnabled else { return }

        Log.default(
            file: file, function: function, line: line,
            String(format: "%@ %@ %.0f ms (total %.0f ms)",
                   label, step(), (now - previous) * 1000, (now - start) * 1000)
        )
    }
}
