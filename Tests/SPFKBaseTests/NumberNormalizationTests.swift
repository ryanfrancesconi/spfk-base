// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation
@testable import SPFKBase
import Testing

@Suite("Number Normalization")
struct NumberNormalizationTests {
    // MARK: - Double

    @Test("normalized is linear at the default taper")
    func normalizedLinear() {
        let value: Double = 50
        #expect(value.normalized(from: 0 ... 100) == 0.5)
    }

    @Test("denormalized is linear at the default taper")
    func denormalizedLinear() {
        let value: Double = 0.5
        #expect(value.denormalized(to: 0 ... 100) == 50)
    }

    @Test("normalized and denormalized round-trip")
    func roundTrip() {
        let original: Double = 75
        let range: ClosedRange<Double> = 0 ... 100
        let result = original.normalized(from: range).denormalized(to: range)
        #expect(abs(result - original) < 0.0001)
    }

    @Test("a taper above 1 pushes the normalized value above linear")
    func taperEffect() {
        let value: Double = 50
        let linear = value.normalized(from: 0 ... 100, taper: 1)
        let curved = value.normalized(from: 0 ... 100, taper: 2)
        #expect(curved > linear)
    }

    @Test("a tapered round-trip returns the original value")
    func taperedRoundTrip() {
        let original: Double = 30
        let range: ClosedRange<Double> = 0 ... 100
        let result = original.normalized(from: range, taper: 3).denormalized(to: range, taper: 3)
        #expect(abs(result - original) < 0.0001)
    }

    // MARK: - Float

    @Test("normalized applies the taper exponent")
    func floatNormalizedWithTaper() {
        let value: Float = 1
        #expect(value.normalized(from: 0 ... 2, taper: 3) == 0.7937005)
    }

    @Test("denormalized is linear at the default taper")
    func floatDenormalized() {
        let value: Float = 0.5
        #expect(value.denormalized(to: 0 ... 100) == 50)
    }

    @Test("normalized and denormalized round-trip")
    func floatRoundTrip() {
        let value: Float = 0.75
        let range: ClosedRange<Float> = 0 ... 100
        let result = value.denormalized(to: range).normalized(from: range)
        #expect(abs(result - value) < 0.0001)
    }
}
