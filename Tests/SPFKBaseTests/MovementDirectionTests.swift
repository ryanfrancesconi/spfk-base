import AudioToolbox
import Foundation
@testable import SPFKBase
import Testing

@Suite("MovementDirection")
struct MovementDirectionTests {
    @Test("raw values")
    func rawValues() {
        #expect(MovementDirection.forward.rawValue == 1)
        #expect(MovementDirection.backward.rawValue == -1)
    }

    @Test("numeric conversions")
    func numericConversions() {
        #expect(MovementDirection.forward.intValue == 1)
        #expect(MovementDirection.backward.intValue == -1)
        #expect(MovementDirection.forward.doubleValue == 1.0)
        #expect(MovementDirection.backward.doubleValue == -1.0)
        #expect(MovementDirection.forward.cgFloat == 1.0)
        #expect(MovementDirection.backward.cgFloat == -1.0)
        #expect(MovementDirection.forward.auValue == AUValue(1))
        #expect(MovementDirection.backward.auValue == AUValue(-1))
    }

    @Test("boolValue")
    func boolValue() {
        #expect(MovementDirection.forward.boolValue == true)
        #expect(MovementDirection.backward.boolValue == false)
    }

    @Test("stringValue")
    func stringValue() {
        #expect(MovementDirection.forward.stringValue == "forward")
        #expect(MovementDirection.backward.stringValue == "backward")
    }

    @Test("inverse")
    func inverse() {
        #expect(MovementDirection.forward.inverse == .backward)
        #expect(MovementDirection.backward.inverse == .forward)
    }

    @Test("init from FloatingPointSign")
    func initFromSign() {
        #expect(MovementDirection(sign: .plus) == .forward)
        #expect(MovementDirection(sign: .minus) == .backward)
    }

    @Test("init from Bool")
    func initFromBool() {
        #expect(MovementDirection(state: true) == .forward)
        #expect(MovementDirection(state: false) == .backward)
    }
}
