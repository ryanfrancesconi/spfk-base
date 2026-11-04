// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation

/// The sentences the running product shows for an error, in its own nouns. Slots, not error
/// types: an error in any package maps its cases onto these, and words itself neutrally when
/// ``current`` is `nil`. Whole sentences rather than nouns, so each language can word them; the
/// titles are the only interpolation.
public struct ProductErrorVocabulary: Sendable {
    public let itemNotFound: String
    public let itemNotFoundNamed: @Sendable (_ title: String) -> String
    public let containerNotFound: String
    public let containerNotFoundForItem: @Sendable (_ itemTitle: String) -> String
    public let containerAlreadyExists: String
    public let itemAlreadyExists: @Sendable (_ title: String) -> String

    /// The running product's wording. Set once at launch, before any window is built.
    public nonisolated(unsafe) static var current: ProductErrorVocabulary?

    public init(
        itemNotFound: String,
        itemNotFoundNamed: @escaping @Sendable (_ title: String) -> String,
        containerNotFound: String,
        containerNotFoundForItem: @escaping @Sendable (_ itemTitle: String) -> String,
        containerAlreadyExists: String,
        itemAlreadyExists: @escaping @Sendable (_ title: String) -> String
    ) {
        self.itemNotFound = itemNotFound
        self.itemNotFoundNamed = itemNotFoundNamed
        self.containerNotFound = containerNotFound
        self.containerNotFoundForItem = containerNotFoundForItem
        self.containerAlreadyExists = containerAlreadyExists
        self.itemAlreadyExists = itemAlreadyExists
    }
}
