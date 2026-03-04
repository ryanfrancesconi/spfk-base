import Foundation
@testable import SPFKBase
import Testing

@Suite("NSException Extensions")
struct NSExceptionTests {
    @Test("error conversion preserves reason and name")
    func errorConversion() {
        let exception = NSException(
            name: NSExceptionName("TestException"),
            reason: "Something went wrong",
            userInfo: nil
        )

        let error = exception.error
        #expect(error.domain == "TestException")
        #expect(error.code == 1)
        #expect(error.localizedDescription == "Something went wrong")
    }

    @Test("error conversion includes callStackSymbols")
    func errorIncludesCallStack() {
        let exception = NSException(
            name: NSExceptionName("TestException"),
            reason: "test",
            userInfo: nil
        )

        let error = exception.error
        let callStack = error.userInfo["callStackSymbols"] as? String
        #expect(callStack != nil)
    }
}
