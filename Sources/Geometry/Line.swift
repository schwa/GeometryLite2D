import CoreGraphics
import SwiftUI

public struct Line {
    public var point: CGPoint         // A point on the line
    public var direction: CGVector    // A non-zero direction vector

    public init(point: CGPoint, direction: CGVector) {
        precondition(direction.dx != 0 || direction.dy != 0, "Direction vector cannot be zero")
        self.point = point
        self.direction = direction
    }

    public init(p1: CGPoint, p2: CGPoint) {
        assert(p1 != p2, "Points must be distinct")
        let dir = CGVector(dx: p2.x - p1.x, dy: p2.y - p1.y)
        self.init(point: p1, direction: dir)
    }
}

extension Line: Sendable {
}

public extension Line {
    init(_ lineSegment: LineSegment) {
        self.init(p1: lineSegment.start, p2: lineSegment.end)
    }

    init(_ ray: Ray) {
        self.init(point: ray.origin, direction: ray.direction)
    }
}

public extension Line {

    func perpendicularThrough(_ p: CGPoint) -> Line {
        let perpDirection = CGVector(dx: -direction.dy, dy: direction.dx)
        return Line(point: p, direction: perpDirection)
    }
}

public extension Line {
    func parallelTo(_ offset: CGFloat) -> Line {
        let unit = direction.normalized

        // Rotate 90° CCW to get the normal vector
        let normal = CGVector(dx: -unit.dy, dy: unit.dx)

        let offsetVector = CGVector(dx: normal.dx * offset, dy: normal.dy * offset)
        return Line(point: point + offsetVector, direction: direction)
    }
}
