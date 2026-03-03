import Foundation
@testable import SPFKBase
import Testing

@Suite("Bool Extensions")
struct BoolExtensionTests {
    @Test("init from BinaryInteger")
    func initFromInteger() {
        let one: Int = 1
        let zero: Int = 0
        let negative: Int = -1
        let large: Int = 42

        #expect(Bool(one) == true)
        #expect(Bool(zero) == false)
        #expect(Bool(negative) == true)
        #expect(Bool(large) == true)
        #expect(Bool(Int8(0)) == false)
        #expect(Bool(UInt32(1)) == true)
    }
}
