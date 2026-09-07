// Copyright Ryan Francesconi. All Rights Reserved.

import Foundation
import SPFKBase
import Testing

/// `simulatedUnavailableFrom` is global, so these must not interleave.
@Suite(.serialized)
struct OSVersionTests {
    /// `#available` and `ProcessInfo` answer the same question by different means. Disagreement
    /// means a case's version literal does not match its name.
    @Test func everyCaseAgreesWithTheRunningSystem() {
        let numbers: [OSVersion: (Int, Int)] = [
            .macOS14: (14, 0),
            .macOS15: (15, 0),
            .macOS15_1: (15, 1),
            .macOS15_2: (15, 2),
            .macOS15_4: (15, 4),
            .macOS26: (26, 0),
        ]

        for version in OSVersion.allCases {
            guard let (major, minor) = numbers[version] else {
                Issue.record("no version number stated for \(version)")
                continue
            }

            let system = ProcessInfo.processInfo.isOperatingSystemAtLeast(
                OperatingSystemVersion(majorVersion: major, minorVersion: minor, patchVersion: 0)
            )

            #expect(version.isAvailable == system, "\(version)")
        }
    }

    @Test func simulationReportsThatVersionAndLaterUnavailable() {
        let real = Set(OSVersion.allCases.filter(\.isAvailable))

        OSVersion.simulatedUnavailableFrom = .macOS15_2
        defer { OSVersion.simulatedUnavailableFrom = nil }

        for version in OSVersion.allCases {
            let expected = real.contains(version) && version < .macOS15_2
            #expect(version.isAvailable == expected, "\(version)")
        }
    }

    @Test func clearingSimulationRestoresTheRunningSystem() {
        let real = Set(OSVersion.allCases.filter(\.isAvailable))

        OSVersion.simulatedUnavailableFrom = .macOS14
        OSVersion.simulatedUnavailableFrom = nil

        #expect(Set(OSVersion.allCases.filter(\.isAvailable)) == real)
    }
}
