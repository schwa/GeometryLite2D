import CoreGraphics
import SwiftUI

public struct Ray {
    public var origin: CGPoint
    public var direction: CGVector  // Should be non-zero

    public init(origin: CGPoint, direction: CGVector) {
        precondition(direction.dx != 0 || direction.dy != 0, "Direction vector cannot be zero.")
        self.origin = origin
        self.direction = direction
    }
}

extension Ray: Sendable {
}

public extension Ray {
    // Create from two points: ray from point1 through point2
    init(from point1: CGPoint, toward point2: CGPoint) {
        let dir = CGVector(dx: point2.x - point1.x, dy: point2.y - point1.y)
        self.init(origin: point1, direction: dir)
    }

    // Get a point at distance t along the ray (t >= 0)
    func point(at t: CGFloat) -> CGPoint {
        CGPoint(x: origin.x + direction.dx * t,
                y: origin.y + direction.dy * t)
    }

    // Check if a point lies on the ray (within tolerance)

    // Project a point onto the ray (clamped to t >= 0)
    func projectedPoint(from point: CGPoint) -> CGPoint {
        let toPoint = CGVector(dx: point.x - origin.x, dy: point.y - origin.y)
        let dirLengthSq = direction.dx * direction.dx + direction.dy * direction.dy
        guard dirLengthSq > 0 else { return origin }

        let dot = direction.dx * toPoint.dx + direction.dy * toPoint.dy
        let t = max(0, dot / dirLengthSq)
        return self.point(at: t)
    }

    func parallelTo(_ offset: CGFloat) -> Ray {
        let unit = direction.normalized

        // Rotate 90° CCW to get the normal vector
        let normal = CGVector(dx: -unit.dy, dy: unit.dx)

        let offsetVector = CGVector(dx: normal.dx * offset, dy: normal.dy * offset)
        return Ray(origin: origin + offsetVector, direction: direction)
    }
}
