import Foundation

extension [Double] {
    public var averaged: Double {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / Double(count)
    }
}

extension [Float] {
    public var averaged: Float {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / Float(count)
    }
}
