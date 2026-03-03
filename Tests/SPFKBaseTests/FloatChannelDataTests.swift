import Foundation
@testable import SPFKBase
import Testing

@Suite("FloatChannelData")
struct FloatChannelDataTests {
    @Test("allocateFloatChannelData creates correct dimensions")
    func allocateDimensions() {
        let data = allocateFloatChannelData(length: 512, channelCount: 2)
        #expect(data.count == 2)
        #expect(data[0].count == 512)
        #expect(data[1].count == 512)
    }

    @Test("allocateFloatChannelData fills with zeros")
    func allocateZeros() {
        let data = allocateFloatChannelData(length: 100, channelCount: 1)
        #expect(data[0].allSatisfy { $0 == 0 })
    }

    @Test("single channel")
    func singleChannel() {
        let data = allocateFloatChannelData(length: 10, channelCount: 1)
        #expect(data.count == 1)
        #expect(data[0].count == 10)
    }
}
