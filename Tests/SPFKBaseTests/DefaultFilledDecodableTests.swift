import Foundation
@testable import SPFKBase
import Testing

/// Decoding a stored value that lacks keys its type has since gained.
struct DefaultFilledDecodableTests {
    struct Inner: Codable, Equatable {
        var amount: Double
        var label: String
    }

    struct Stored: DefaultFilledDecodable, Equatable {
        var inner: Inner
        var values: [Int]
        var flag: Bool

        static let decodingDefaults = Stored(inner: Inner(amount: 0.5, label: "default"), values: [1, 2, 3], flag: true)
    }

    private func decode(_ json: String) throws -> Stored {
        try JSONDecoder().decode(Stored.self, from: Data(json.utf8), fillingGapsFrom: Stored.decodingDefaults)
    }

    @Test func aMissingNestedKeyTakesTheDefault() throws {
        let value = try decode(#"{"inner": {"label": "kept"}, "values": [9], "flag": false}"#)
        #expect(value == Stored(inner: Inner(amount: 0.5, label: "kept"), values: [9], flag: false))
    }

    @Test func aMissingSectionTakesTheDefaultWhole() throws {
        let value = try decode(#"{"values": [9], "flag": false}"#)
        #expect(value.inner == Stored.decodingDefaults.inner)
    }

    @Test func presentValuesWinOverTheDefault() throws {
        let original = Stored(inner: Inner(amount: 1.0 / 3.0, label: "x"), values: [], flag: false)
        let data = try JSONEncoder().encode(original)
        let value = try JSONDecoder().decode(Stored.self, from: data, fillingGapsFrom: Stored.decodingDefaults)
        #expect(value == original)
    }

    @Test func anArrayIsReplacedNotMerged() throws {
        let value = try decode(#"{"inner": {"amount": 1, "label": "a"}, "values": [7], "flag": true}"#)
        #expect(value.values == [7])
    }

    @Test func anUnknownKeyIsIgnored() throws {
        let value = try decode(#"{"inner": {"amount": 1, "label": "a", "later": 4}, "values": [], "flag": true, "newer": {}}"#)
        #expect(value == Stored(inner: Inner(amount: 1, label: "a"), values: [], flag: true))
    }

    @Test func aTopLevelArrayThrows() {
        #expect(throws: DecodingError.self) { try decode("[1, 2]") }
    }

    @Test func aTypeMismatchStillThrows() {
        #expect(throws: DecodingError.self) { try decode(#"{"inner": {"amount": "loud"}}"#) }
        #expect(throws: DecodingError.self) { try decode(#"{"inner": 4}"#) }
    }

    @Test func theProtocolStaticFillsFromItsDefaults() throws {
        let value = try Stored.decodeFillingGaps(from: Data(#"{"flag": false}"#.utf8))
        #expect(value == Stored(inner: Stored.decodingDefaults.inner, values: [1, 2, 3], flag: false))
    }
}
