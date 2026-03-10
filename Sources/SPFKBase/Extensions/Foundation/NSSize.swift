// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-utils

import Foundation

extension CGSize {
    public var centerPoint: CGPoint {
        CGPoint(x: width / 2, y: height / 2)
    }

    public static let one = CGSize(width: 1, height: 1)
}
