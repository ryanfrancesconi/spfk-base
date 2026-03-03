import Foundation
@testable import SPFKBase
import Testing

@Suite("BuildConfig")
struct BuildConfigTests {
    @Test("description values")
    func description() {
        #expect(BuildConfig.debug.description == "DEBUG")
        #expect(BuildConfig.beta.description == "BETA")
        #expect(BuildConfig.publicBeta.description == "PUBLIC BETA")
        #expect(BuildConfig.release.description == "")
        #expect(BuildConfig.testing.description == "Testing only")
    }

    @Test("isInternal for debug, beta, testing only")
    func isInternal() {
        #expect(BuildConfig.debug.isInternal)
        #expect(BuildConfig.beta.isInternal)
        #expect(BuildConfig.testing.isInternal)
        #expect(!BuildConfig.publicBeta.isInternal)
        #expect(!BuildConfig.release.isInternal)
    }

    @Test("isBeta is true for everything except release")
    func isBeta() {
        #expect(BuildConfig.debug.isBeta)
        #expect(BuildConfig.beta.isBeta)
        #expect(BuildConfig.publicBeta.isBeta)
        #expect(BuildConfig.testing.isBeta)
        #expect(!BuildConfig.release.isBeta)
    }

    @Test("isRelease only for release")
    func isRelease() {
        #expect(BuildConfig.release.isRelease)
        #expect(!BuildConfig.debug.isRelease)
        #expect(!BuildConfig.beta.isRelease)
        #expect(!BuildConfig.publicBeta.isRelease)
        #expect(!BuildConfig.testing.isRelease)
    }

    @Test("all cases are present")
    func allCases() {
        #expect(BuildConfig.allCases.count == 5)
    }
}
