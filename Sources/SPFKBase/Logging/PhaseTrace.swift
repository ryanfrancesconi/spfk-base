// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation

/// Step timing for a path that gets measured repeatedly, left in the code rather than added and
/// stripped each time.
///
/// Logs through `Log.default` rather than `Log.debug` because a load path has to be measured in
/// release, where `Log.debug` is compiled out.
public struct PhaseTrace {
    /// Whether marks are logged. Set by the app at launch, like ``Log/buildConfig``; how it decides
    /// is the app's own business.
    public nonisolated(unsafe) static var isEnabled = false

    private let label: String
    private let start: TimeInterval
    private var previous: TimeInterval

    /// - Parameter label: the prefix every mark is logged under. The default is the playlist and
    ///   album load path's, so one search finds all of it.
    public init(_ label: String = "LOADTRACE") {
        self.label = label
        start = ProcessInfo.processInfo.systemUptime
        previous = start
    }

    public mutating func mark(
        _ step: @autoclosure () -> String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let now = ProcessInfo.processInfo.systemUptime
        defer { previous = now }

        guard Self.isEnabled else { return }

        // `@` is system uptime, so marks from separate traces can be ordered against each other.
        Log.default(
            file: file, function: function, line: line,
            String(format: "%@ %@ %.0f ms (total %.0f ms) @%.3f",
                   label, step(), (now - previous) * 1000, (now - start) * 1000, now)
        )
    }
}
