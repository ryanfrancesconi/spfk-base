import Foundation
@testable import SPFKBase
import Testing

@Suite("FloatingPoint Extensions")
struct FloatingPointTests {
    @Test("round to divisor")
    func roundToDivisor() {
        #expect(7.3.round(divisor: 5.0) == 5.0)
        #expect(8.0.round(divisor: 5.0) == 10.0)
        #expect(12.5.round(divisor: 5.0) == 15.0)
        #expect(0.0.round(divisor: 5.0) == 0.0)
    }

    @Test("round with zero divisor returns self")
    func roundZeroDivisor() {
        #expect(7.3.round(divisor: 0.0) == 7.3)
        #expect(7.3.round(divisor: -1.0) == 7.3)
    }

    @Test("mean of non-empty array")
    func mean() {
        let values: [Float] = [2, 4, 6]
        #expect(values.mean() == 4.0)

        let doubles: [Double] = [10, 20, 30]
        #expect(doubles.mean() == 20.0)
    }

    @Test("unitIntervalRange is 0...1")
    func unitIntervalRange() {
        #expect(Double.unitIntervalRange == 0 ... 1)
        #expect(Float.unitIntervalRange == 0 ... 1)
    }

    @Test("averaged property on concrete types")
    func averaged() {
        let doubles: [Double] = [10, 20, 30]
        #expect(doubles.averaged == 20.0)

        let floats: [Float] = [3, 6, 9]
        #expect(floats.averaged == 6.0)
    }

    @Test("mean of empty array returns zero")
    func meanEmpty() {
        #expect([Float]().mean() == 0)
        #expect([Double]().mean() == 0)
    }

    @Test("averaged of empty array returns zero")
    func averagedEmpty() {
        #expect([Double]().averaged == 0)
        #expect([Float]().averaged == 0)
    }
}
