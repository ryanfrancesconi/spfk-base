import Foundation
@testable import SPFKBase
import Testing

@Suite("BuildConfig")
struct BuildConfigTests {
    @Test("description values")
    func description() {
        #expect(BuildConfig.debug.description == "Debug")
        #expect(BuildConfig.beta.description == "Beta")
        #expect(BuildConfig.release.description == "Release")
    }

    @Test("isBeta is true for everything except release")
    func isBeta() {
        #expect(BuildConfig.debug.isBeta)
        #expect(BuildConfig.beta.isBeta)
        #expect(!BuildConfig.release.isBeta)
    }

    @Test("isRelease only for release")
    func isRelease() {
        #expect(BuildConfig.release.isRelease)
        #expect(!BuildConfig.debug.isRelease)
        #expect(!BuildConfig.beta.isRelease)
    }

    @Test("all cases are present")
    func allCases() {
        #expect(BuildConfig.allCases.count == 3)
    }
}
