import CoreGraphics
import simd
import SwiftUI

public extension CGPoint {
    init(_ point: SIMD2<Float>) {
        self.init(x: Double(point.x), y: Double(point.y))
    }
}

public extension CGSize {
    init(_ point: SIMD2<Float>) {
        self.init(width: Double(point.x), height: Double(point.y))
    }
}
