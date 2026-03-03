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
}
