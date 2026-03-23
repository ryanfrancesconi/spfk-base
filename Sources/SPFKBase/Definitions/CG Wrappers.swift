// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import CoreFoundation

/// Namespace for Codable wrappers of CG* types.
public enum CG {
    public struct Rect: Codable, Sendable, Equatable, Hashable {
        public let x: CGFloat
        public let y: CGFloat
        public let width: CGFloat
        public let height: CGFloat

        public var cgPoint: CGPoint {
            CGPoint(x: x, y: y)
        }

        public var cgSize: CGSize {
            CGSize(width: width, height: height)
        }

        public var cgRect: CGRect {
            CGRect(x: x, y: y, width: width, height: height)
        }

        public init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
            self.x = x
            self.y = y
            self.width = width
            self.height = height
        }

        public init(cgRect: CGRect) {
            x = cgRect.origin.x
            y = cgRect.origin.y
            width = cgRect.width
            height = cgRect.height
        }
    }

    public struct Size: Codable, Sendable, Equatable, Hashable {
        public let width: CGFloat
        public let height: CGFloat

        public var cgSize: CGSize {
            CGSize(width: width, height: height)
        }

        public init(width: CGFloat, height: CGFloat) {
            self.width = width
            self.height = height
        }
    }

    public struct Point: Codable, Sendable, Equatable, Hashable {
        public let x: CGFloat
        public let y: CGFloat

        public var cgPoint: CGPoint {
            CGPoint(x: x, y: y)
        }

        public init(x: CGFloat, y: CGFloat) {
            self.x = x
            self.y = y
        }
    }
}
