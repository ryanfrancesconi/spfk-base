// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation

extension Task where Success == Never, Failure == Never {
    public static func sleep(seconds: TimeInterval) async throws {
        if #available(macOS 13, iOS 16, *) {
            try await Task.sleep(for: .seconds(seconds))

        } else {
            let nanoseconds = UInt64(seconds * 1000000000)
            try await Task.sleep(nanoseconds: nanoseconds)
        }
    }
}
