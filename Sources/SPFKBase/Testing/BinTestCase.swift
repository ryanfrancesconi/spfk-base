import Foundation

/// Test case base class for Swift Testing where temp media files are needed.
/// All functionality is in `TestCaseModel`.
///
/// Lives in SPFKBase (rather than SPFKTesting) because `TestCaseModel` depends on
/// SPFKBase utilities. See `TestCaseModel` for details.
open class BinTestCase: TestCaseModel {
    /// Temp files will be written here. Each instance gets a unique UUID subdirectory so
    /// parallel tests in the same suite don't race on deinit cleanup.
    public private(set) lazy var bin: URL = createBin(suite: "\(typeName)-\(UUID().uuidString)")

    /// in cases where you want to check the actual files after the test completes
    /// can set this to false to leave in temp
    public var deleteBinOnExit = true

    public init() async {}

    deinit {
        guard deleteBinOnExit,
            bin.exists,
            bin != defaultURL
        else { return }
        removeBin()
    }
}
