// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-utils

import Foundation
import SPFKTesting
import Testing

@testable import SPFKBase

class SerializableTests: TestCaseModel {
    private struct TestModel: Serializable, Equatable {
        var name: String
        var value: Int
    }

    @Test func jsonRoundTrip() throws {
        let original = TestModel(name: "hello", value: 42)
        let json = try #require(original.jsonRepresentation)
        let decoded = try TestModel(json: json)
        #expect(decoded == original)
    }

    @Test func jsonRepresentationIsValidJSON() throws {
        let model = TestModel(name: "test", value: 1)
        let json = try #require(model.jsonRepresentation)
        let data = try #require(json.data(using: .utf8))
        #expect(throws: Never.self) {
            _ = try JSONSerialization.jsonObject(with: data)
        }
    }

    @Test func initJsonThrowsOnInvalidInput() {
        #expect(throws: (any Error).self) {
            _ = try TestModel(json: "not valid json")
        }
    }
}
