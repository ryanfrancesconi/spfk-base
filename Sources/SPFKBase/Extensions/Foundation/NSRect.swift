// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import CoreGraphics
import Foundation

extension CGRect {
    public init(size: CGSize) {
        self = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
    }

    public init(width: CGFloat, height: CGFloat) {
        self = CGRect(x: 0, y: 0, width: width, height: height)
    }

    public init(width: Int, height: Int) {
        self = CGRect(x: 0, y: 0, width: width, height: height)
    }
}
