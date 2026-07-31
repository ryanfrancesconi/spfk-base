import Foundation
@testable import SPFKBase
import Testing

@Suite("String Extensions")
struct StringTests {
    // MARK: - Character Filters

    @Test("onlyASCIIAlphanumericsPlusMinusUnderscore strips invalid characters")
    func asciiFilter() {
        #expect("Hello World!@#$%".onlyASCIIAlphanumericsPlusMinusUnderscore() == "Hello World")
        #expect("a+b-c_d".onlyASCIIAlphanumericsPlusMinusUnderscore() == "a+b-c_d")
        #expect("café".onlyASCIIAlphanumericsPlusMinusUnderscore() == "caf")
        #expect("".onlyASCIIAlphanumericsPlusMinusUnderscore() == "")
    }

    @Test("normalizedWhitespaces replaces non-breaking spaces")
    func normalizedWhitespace() {
        let input = "hello\u{00A0}world"
        #expect(input.normalizedWhitespaces() == "helloworld")
    }

    @Test("abbreviated produces short identifiers")
    func abbreviated() {
        #expect("MyClassName".abbreviated == "MCN")
        #expect("hello world".abbreviated == "HW")
        #expect("AB".abbreviated == "AB")
        #expect("ABCDEF".abbreviated == "ABCD")
        #expect("x".abbreviated == "")
        #expect("ab".abbreviated == "AB")
    }

    @Test("spacedTitleCased converts camelCase")
    func spacedTitleCased() {
        #expect("theCamel".spacedTitleCased == "The Camel")
        #expect("helloWorld".spacedTitleCased == "Hello World")
    }

    @Test("snakeCaseWords splits identifiers into component words")
    func snakeCaseWords() {
        #expect("toaster_oven".snakeCaseWords == ["toaster", "oven"])
        #expect("bicycle".snakeCaseWords == ["bicycle"])
        #expect("".snakeCaseWords == [])

        // Whitespace separates too, so an already-spaced identifier decomposes the same way
        // rather than coming back as one word.
        #expect("toaster oven".snakeCaseWords == ["toaster", "oven"])

        // Repeated and edge separators must not yield empty words -- those would become
        // doubled spaces once rejoined.
        #expect("__toaster__oven__".snakeCaseWords == ["toaster", "oven"])
    }

    @Test("snakeCaseToTitle converts identifiers to display form")
    func snakeCaseToTitle() {
        #expect("toaster_oven".snakeCaseToTitle == "Toaster Oven")
        #expect("dog_bark".snakeCaseToTitle == "Dog Bark")
        #expect("bicycle".snakeCaseToTitle == "Bicycle")
        #expect("".snakeCaseToTitle == "")

        // Inherits titleCased's particle rules: a particle between the first and last word
        // stays lowercase.
        #expect("bird_of_prey".snakeCaseToTitle == "Bird of Prey")

        // Edge separators must not survive as doubled spaces.
        #expect("__toaster__oven__".snakeCaseToTitle == "Toaster Oven")
    }

    // MARK: - Comparison

    @Test("equalsIgnoringCase works")
    func equalsIgnoringCase() {
        #expect("Hello".equalsIgnoringCase("hello"))
        #expect("ABC".equalsIgnoringCase("abc"))
        #expect(!"abc".equalsIgnoringCase("def"))
    }

    @Test("standardCompare sorts correctly")
    func standardCompare() {
        #expect("apple".standardCompare(with: "banana", ascending: true))
        #expect(!"banana".standardCompare(with: "apple", ascending: true))
        #expect("banana".standardCompare(with: "apple", ascending: false))
    }

    // MARK: - Delimited Strings

    @Test("splitDelimited parses correctly")
    func splitDelimited() {
        let result = "a, b, c".splitDelimited()
        #expect(result == ["a", "b", "c"])

        let withDupes = "a, b, a".splitDelimited(allowDuplicates: true)
        #expect(withDupes == ["a", "b", "a"])

        let noDupes = "a, b, A".splitDelimited(allowDuplicates: false)
        #expect(noDupes.count == 2)

        let empty = "".splitDelimited()
        #expect(empty.isEmpty)
    }

    // MARK: - Conversions

    @Test("boolValue parses correctly")
    func boolValue() {
        #expect("true".boolValue == true)
        #expect("True".boolValue == true)
        #expect("TRUE".boolValue == true)
        #expect("1".boolValue == true)
        #expect("false".boolValue == false)
        #expect("0".boolValue == false)
        #expect("anything".boolValue == false)
    }

    @Test("urlEncoded encodes special characters")
    func urlEncoded() {
        #expect("hello world".urlEncoded == "hello%20world")
        #expect("a&b=c".urlEncoded != nil)
        #expect("simple".urlEncoded == "simple")
    }

    @Test("urlQueryEncoded uses plus for spaces")
    func urlQueryEncoded() {
        #expect("hello world".urlQueryEncoded == "hello+world")
    }

    // MARK: - urlAllowed CharacterSet

    @Test("urlAllowed contains RFC 3986 unreserved characters")
    func urlAllowedCharacterSet() {
        let allowed = CharacterSet.urlAllowed
        #expect(allowed.isSuperset(of: .alphanumerics))
        #expect("-._~".unicodeScalars.allSatisfy { allowed.contains($0) })
    }
}
