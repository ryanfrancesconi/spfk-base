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

    @Test("osStatus parsed from AVFoundation-style reason string")
    func osStatusParsedFromReason() {
        // Simulates the exception AVAudioEngine throws when SetFormat fails:
        // reason contains "Code=<OSStatus>" embedded in the description string.
        let reason = "[[busArray objectAtIndexedSubscript:0] setFormat:format error:&nsErr]: returned false, error Error Domain=NSOSStatusErrorDomain Code=-10868 \"(null)\""
        let exception = NSException(
            name: NSExceptionName("com.apple.coreaudio.avfaudio"),
            reason: reason,
            userInfo: nil
        )

        let error = exception.error
        #expect(error.osStatus == OSStatus(-10868))
    }

    @Test("osStatus promoted from structured NSError in userInfo")
    func osStatusFromUserInfo() {
        let underlying = NSError(domain: NSOSStatusErrorDomain, code: -10868)
        let exception = NSException(
            name: NSExceptionName("com.apple.coreaudio.avfaudio"),
            reason: "format not supported",
            userInfo: ["Error": underlying]
        )

        let error = exception.error
        #expect(error.osStatus == OSStatus(-10868))
    }

    @Test("osStatus is nil when no OSStatus is present")
    func osStatusNilForPlainError() {
        let exception = NSException(
            name: NSExceptionName("TestException"),
            reason: "Something went wrong",
            userInfo: nil
        )

        #expect(exception.error.osStatus == nil)
    }

    @Test("osStatus is nil for non-OSStatus underlying error")
    func osStatusNilForNonOSStatusUnderlying() {
        let underlying = NSError(domain: "com.example.other", code: 42)
        let exception = NSException(
            name: NSExceptionName("TestException"),
            reason: "wrapped error",
            userInfo: ["Error": underlying]
        )

        #expect(exception.error.osStatus == nil)
    }
}
