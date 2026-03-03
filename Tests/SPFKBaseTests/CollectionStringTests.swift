import Foundation
@testable import SPFKBase
import Testing

@Suite("Collection String Extensions")
struct CollectionStringTests {
    @Test("pluralString returns s for non-one counts")
    func pluralString() {
        #expect([1, 2, 3].pluralString == "s")
        #expect([1].pluralString == "")
        #expect([Int]().pluralString == "s")
    }

    @Test("delimitedString joins strings")
    func delimitedStringFromStrings() {
        #expect(["a", "b", "c"].delimitedString() == "a, b, c")
        #expect(["a", "b"].delimitedString(delimiter: "|") == "a|b")
        #expect([String]().delimitedString() == "")
    }

    @Test("delimitedString joins integers")
    func delimitedStringFromIntegers() {
        #expect([1, 2, 3].delimitedString() == "1, 2, 3")
        #expect([10, 20].delimitedString(delimiter: "-") == "10-20")
    }

    @Test("delimitedString joins floats")
    func delimitedStringFromFloats() {
        let result = [1.5, 2.5].delimitedString()
        #expect(result.contains("1.5"))
        #expect(result.contains("2.5"))
    }

    @Test("contains caseInsensitive")
    func containsCaseInsensitive() {
        let items = ["Hello", "World"]
        #expect(items.contains(caseInsensitive: "hello"))
        #expect(items.contains(caseInsensitive: "WORLD"))
        #expect(!items.contains(caseInsensitive: "missing"))
    }

    @Test("compactMapInt trims and parses")
    func compactMapInt() {
        let result = [" 1 ", "2", " abc", "3"].compactMapInt()
        #expect(result == [1, 2, 3])
    }

    @Test("compactMapUInt32 trims and parses")
    func compactMapUInt32() {
        let result = [" 10 ", "20", "bad"].compactMapUInt32()
        #expect(result == [10, 20])
    }

    @Test("compactMapDouble trims and parses")
    func compactMapDouble() {
        let result = [" 1.5 ", "2.0", "nope"].compactMapDouble()
        #expect(result == [1.5, 2.0])
    }
}
