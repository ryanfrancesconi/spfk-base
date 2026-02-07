import Foundation

extension [Double] {
    public var averaged: Double {
        reduce(0, +) / Double(count)
    }
}

extension [Float] {
    public var averaged: Float {
        reduce(0, +) / Float(count)
    }
}
