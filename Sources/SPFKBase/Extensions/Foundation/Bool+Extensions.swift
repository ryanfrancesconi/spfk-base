// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-base

import Foundation

extension Bool {
    public init(_ integer: some BinaryInteger) {
        self.init(integer != 0)
    }
}
