import CoreGraphics
import Foundation
@testable import SPFKBase
import Testing

@Suite("Geometry Extensions")
struct GeometryTests {
    // MARK: - CGRect

    @Test("CGRect init from CGSize")
    func rectFromSize() {
        let rect = CGRect(size: CGSize(width: 100, height: 200))
        #expect(rect.origin == CGPoint.zero)
        #expect(rect.size == CGSize(width: 100, height: 200))
    }

    @Test("CGRect init from CGFloat dimensions")
    func rectFromCGFloats() {
        let rect = CGRect(width: CGFloat(50), height: CGFloat(75))
        #expect(rect.origin == CGPoint.zero)
        #expect(rect.width == 50)
        #expect(rect.height == 75)
    }

    @Test("CGRect init from Int dimensions")
    func rectFromInts() {
        let rect = CGRect(width: 320, height: 240)
        #expect(rect.origin == CGPoint.zero)
        #expect(rect.width == 320)
        #expect(rect.height == 240)
    }

    // MARK: - CGSize

    @Test("centerPoint")
    func centerPoint() {
        let size = CGSize(width: 100, height: 200)
        #expect(size.centerPoint == CGPoint(x: 50, y: 100))
    }

    @Test("centerPoint for zero size")
    func centerPointZero() {
        let size = CGSize.zero
        #expect(size.centerPoint == CGPoint.zero)
    }
}
