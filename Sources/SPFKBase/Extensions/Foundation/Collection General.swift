// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation

extension Sequence where Element: Hashable {
    /// Key: The element. Value: how many times it occurs.
    public var elementQuantity: [Element: Int] {
        reduce(into: [:]) {
            $0[$1, default: 0] += 1
        }
    }
}

extension Collection {
    /// A Boolean value indicating whether the collection is not empty.
    public var isNotEmpty: Bool {
        !isEmpty
    }
}

extension RangeReplaceableCollection where Iterator.Element: ExpressibleByIntegerLiteral {
    /// Initialize array with zeros, ~10x faster than append for array of size 4096
    /// - parameter count: Number of elements in the array
    public init(zeros count: Int) {
        self.init(repeating: 0, count: count)
    }
}

extension Array where Element: Equatable {
    public mutating func move(element: Element, to newIndex: Index) throws {
        guard !isEmpty else {
            throw NSError(description: "Array is empty")
        }

        guard let index = firstIndex(of: element) else {
            throw NSError(description: "Didn't find \(element) in array")
        }

        guard index != newIndex else {
            throw NSError(description: "\(element) is already at index \(newIndex)")
        }

        try move(index: index, to: newIndex)
    }

    public mutating func move(index: Index, to newIndex: Index) throws {
        guard indices.contains(index) else {
            throw NSError(description: "Invalid index (\(index)) to move")
        }

        let element = remove(at: index)

        let newIndex = newIndex.clamped(to: 0 ... count)

        insert(element, at: newIndex)
    }

    public mutating func bringToFront(element: Element) throws {
        try move(element: element, to: 0)
    }

    public mutating func sendToBack(element: Element) throws {
        try move(element: element, to: endIndex - 1)
    }
}
