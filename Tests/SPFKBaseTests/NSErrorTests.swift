import Foundation
@testable import SPFKBase
import Testing

@Suite("NSError Extensions")
struct NSErrorTests {
    @Test("convenience init with description")
    func initWithDescription() {
        let error = NSError(description: "something failed")
        #expect(error.localizedDescription == "something failed")
        #expect(error.code == 1)
        #expect(error.domain == Log.defaultSubsystem)
    }

    @Test("convenience init with custom domain and code")
    func initWithCustomDomainAndCode() {
        let error = NSError(domain: "custom.domain", code: 42, description: "custom error")
        #expect(error.domain == "custom.domain")
        #expect(error.code == 42)
        #expect(error.localizedDescription == "custom error")
    }

    @Test("convenience init with file and function")
    func initWithFileAndFunction() {
        let error = NSError(
            file: "/path/to/MyFile.swift",
            function: "doSomething()",
            description: "it broke"
        )
        #expect(error.localizedDescription.contains("MyFile.swift"))
        #expect(error.localizedDescription.contains("doSomething()"))
        #expect(error.localizedDescription.contains("it broke"))
    }

    // MARK: - informativeDescription

    private enum UndescribedError: Error { case failed }

    private enum DescribedError: LocalizedError {
        case failed
        var errorDescription: String? { "the file is gone" }
    }

    @Test("informativeDescription is nil for Foundation's domain-and-code fallback")
    func informativeDescriptionNilForFallback() {
        #expect(NSError(domain: NSOSStatusErrorDomain, code: -39).informativeDescription == nil)
        #expect(NSError(domain: "com.apple.coreaudio.avfaudio", code: 2_003_334_207).informativeDescription == nil)
        // The shape `_GenericObjCError` bridges to: a Swift error type with no description.
        #expect(UndescribedError.failed.informativeDescription == nil)
    }

    @Test("informativeDescription keeps a real description")
    func informativeDescriptionKeepsRealDescription() {
        #expect(NSError(description: "something failed").informativeDescription == "something failed")
        #expect(DescribedError.failed.informativeDescription == "the file is gone")
        #expect(CocoaError(.fileNoSuchFile).informativeDescription != nil)
    }
}
