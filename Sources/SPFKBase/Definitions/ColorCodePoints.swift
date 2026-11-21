// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation

/// A picture's color as ITU-T H.273 code points: its color primaries, transfer characteristics and
/// matrix coefficients. 2 is "unspecified" in each.
public struct ColorCodePoints: Hashable, Sendable {
    public var primaries: Int
    public var transfer: Int
    public var matrix: Int

    public init(primaries: Int, transfer: Int, matrix: Int) {
        self.primaries = primaries
        self.transfer = transfer
        self.matrix = matrix
    }

    public static let rec709 = ColorCodePoints(primaries: 1, transfer: 1, matrix: 1)
    public static let rec2020HLG = ColorCodePoints(primaries: 9, transfer: 18, matrix: 9)
}
