// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import CoreFoundation
import Foundation
import SPFKTesting
import Testing

@testable import SPFKBase

final class CGWrappersTests: TestCaseModel {
    // MARK: - CG.Rect

    @Test func rectInitFromValues() {
        let rect = CG.Rect(x: 10, y: 20, width: 100, height: 200)
        #expect(rect.x == 10)
        #expect(rect.y == 20)
        #expect(rect.width == 100)
        #expect(rect.height == 200)
    }

    @Test func rectInitFromCGRect() {
        let cgRect = CGRect(x: 5, y: 15, width: 50, height: 75)
        let rect = CG.Rect(cgRect: cgRect)
        #expect(rect.x == 5)
        #expect(rect.y == 15)
        #expect(rect.width == 50)
        #expect(rect.height == 75)
    }

    @Test func rectToCGRect() {
        let rect = CG.Rect(x: 1, y: 2, width: 3, height: 4)
        let cgRect = rect.cgRect
        #expect(cgRect.origin.x == 1)
        #expect(cgRect.origin.y == 2)
        #expect(cgRect.size.width == 3)
        #expect(cgRect.size.height == 4)
    }

    @Test func rectCGPoint() {
        let rect = CG.Rect(x: 10, y: 20, width: 100, height: 200)
        #expect(rect.cgPoint == CGPoint(x: 10, y: 20))
    }

    @Test func rectCGSize() {
        let rect = CG.Rect(x: 10, y: 20, width: 100, height: 200)
        #expect(rect.cgSize == CGSize(width: 100, height: 200))
    }

    @Test func rectRoundTrip() {
        let original = CGRect(x: 3.5, y: 7.25, width: 100.5, height: 200.75)
        let rect = CG.Rect(cgRect: original)
        #expect(rect.cgRect == original)
    }

    @Test func rectCodable() throws {
        let rect = CG.Rect(x: 10, y: 20, width: 30, height: 40)
        let data = try JSONEncoder().encode(rect)
        let decoded = try JSONDecoder().decode(CG.Rect.self, from: data)
        #expect(decoded == rect)
    }

    @Test func rectEquatable() {
        let a = CG.Rect(x: 1, y: 2, width: 3, height: 4)
        let b = CG.Rect(x: 1, y: 2, width: 3, height: 4)
        let c = CG.Rect(x: 5, y: 6, width: 7, height: 8)
        #expect(a == b)
        #expect(a != c)
    }

    // MARK: - CG.Size

    @Test func sizeInitAndConversion() {
        let size = CG.Size(width: 640, height: 480)
        #expect(size.width == 640)
        #expect(size.height == 480)
        #expect(size.cgSize == CGSize(width: 640, height: 480))
    }

    @Test func sizeCodable() throws {
        let size = CG.Size(width: 1920, height: 1080)
        let data = try JSONEncoder().encode(size)
        let decoded = try JSONDecoder().decode(CG.Size.self, from: data)
        #expect(decoded == size)
    }

    @Test func sizeEquatable() {
        let a = CG.Size(width: 100, height: 200)
        let b = CG.Size(width: 100, height: 200)
        let c = CG.Size(width: 300, height: 400)
        #expect(a == b)
        #expect(a != c)
    }

    // MARK: - CG.Point

    @Test func pointInitAndConversion() {
        let point = CG.Point(x: 42, y: 84)
        #expect(point.x == 42)
        #expect(point.y == 84)
        #expect(point.cgPoint == CGPoint(x: 42, y: 84))
    }

    @Test func pointCodable() throws {
        let point = CG.Point(x: 3.14, y: 2.72)
        let data = try JSONEncoder().encode(point)
        let decoded = try JSONDecoder().decode(CG.Point.self, from: data)
        #expect(decoded == point)
    }

    @Test func pointEquatable() {
        let a = CG.Point(x: 10, y: 20)
        let b = CG.Point(x: 10, y: 20)
        let c = CG.Point(x: 30, y: 40)
        #expect(a == b)
        #expect(a != c)
    }
}
