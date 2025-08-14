import CoreGraphics
import simd
import SwiftUI

public extension SIMD3 {
    var xz: SIMD2<Scalar> {
        [x, z]
    }
}

public extension SIMD4 {
    var xz: SIMD2<Scalar> {
        [x, z]
    }
    var xyz: SIMD3<Scalar> {
        [x, y, z]
    }
}

public extension simd_float4x4 {
    var yaw: Angle {
        Angle(radians: Double(atan2(-columns.2.x, columns.0.x)))
    }

    var translation: SIMD3<Float> {
        columns.3.xyz
    }

    var scale: SIMD3<Float> {
        SIMD3<Float>(
            length(columns.0.xyz),
            length(columns.1.xyz),
            length(columns.2.xyz)
        )
    }
}

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
