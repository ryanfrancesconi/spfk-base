import Foundation
import SPFKBase
import SPFKBaseC
import Testing

final class CollectionTests: TestCaseModel {
    @Test func move() async throws {
        var array = ["0", "1", "2", "3", "4"]

        try array.move(element: "1", to: 0)
        #expect(array == ["1", "0", "2", "3", "4"])

        try array.move(element: "0", to: 4)
        #expect(array == ["1", "2", "3", "4", "0"])

        try array.move(element: "0", to: 10) // clamp
        #expect(array == ["1", "2", "3", "4", "0"])

        try array.move(element: "0", to: -10) // clamp
        #expect(array == ["0", "1", "2", "3", "4"])

        try array.move(index: 1, to: 0)
        #expect(array == ["1", "0", "2", "3", "4"])

        #expect(throws: (any Error).self) {
            try array.move(index: 10, to: 0)
        }
    }

    @Test func bringToFront() async throws {
        var array = ["0", "1", "2", "3", "4"]

        try array.bringToFront(element: "4")
        #expect(array.first == "4")
    }

    @Test func sendToBack() async throws {
        var array = ["0", "1", "2", "3", "4"]

        try array.sendToBack(element: "0")
        #expect(array.last == "0")
    }
}
