#if canImport(CoreGraphics)
import CoreGraphics
#else
import Foundation
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(Glibc)
import Glibc
#endif

public struct LineSegment {
    public var start: CGPoint
    public var end: CGPoint

    public init(start: CGPoint, end: CGPoint) {
        self.start = start
        self.end = end
    }
}

extension LineSegment: Equatable {
}

extension LineSegment: Hashable {
}

extension LineSegment: Sendable {
}

// MARK: -

public extension LineSegment {
    init(_ start: CGPoint, _ end: CGPoint) {
        self.start = start
        self.end = end
    }

    var points: [CGPoint] {
        [start, end]
    }

    var mid: CGPoint {
        (start + end) / 2
    }

    var length: CGFloat {
        (end - start).length
    }

    var angle: Angle {
        Angle(radians: atan2(end.y - start.y, end.x - start.x))
    }

    var direction: CGVector {
        CGVector((end - start).normalized)
    }

    var normal: CGVector {
        direction.perpendicular.normalized
    }
}

// MARK: -

public extension LineSegment {
    func contains(_ point: CGPoint, interior: Bool, epsilon: CGFloat = 1e-5) -> Bool {
        contains(point, epsilon: epsilon) && (!interior || (point != start && point != end))
    }

    func contains(_ point: CGPoint, epsilon: CGFloat = 1e-5) -> Bool {
        let vectorToPoint = point - start
        let direction = end - start
        let length = direction.length

        // Handle degenerate case
        guard length > epsilon else {
            return (point - start).length <= epsilon
        }

        let axis = direction.normalized
        let projectionLength = vectorToPoint.dot(axis)

        // Projected point must lie between 0 and segment length
        guard projectionLength >= -epsilon, projectionLength <= length + epsilon else {
            return false
        }

        // Compute the closest point on the segment
        let projectedPoint = start + axis * projectionLength
        return (projectedPoint - point).length <= epsilon
    }

    func contains(_ lineSegment: LineSegment, epsilon: CGFloat = 1e-5) -> Bool {
        contains(lineSegment.start, epsilon: epsilon) && contains(lineSegment.end, epsilon: epsilon)
    }
}

public extension LineSegment {
    var vector: CGVector {
        CGVector(end - start)
    }
}
