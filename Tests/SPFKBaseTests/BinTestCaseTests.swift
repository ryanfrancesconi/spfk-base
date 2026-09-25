// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation
import SPFKTesting
import Testing

@testable import SPFKBase

@Suite(.tags(.file))
final class BinTestCaseTests: BinTestCase {
    @Test func copyToBinThenRemoveBin() throws {
        let copy = try copyToBin(url: TestBundleResources.shared.mp3_no_metadata)
        #expect(copy.exists)

        removeBin()
        #expect(!copy.exists)
    }
}
