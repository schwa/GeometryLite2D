import CoreGraphics
import Foundation

// MARK: - Geometry Utilities

public struct GeometryUtils {
    /// Sort points by angle from a central point
    public static func sortByAngle(points: [CGPoint], center: CGPoint) -> [CGPoint] {
        points.sorted { p1, p2 in
            let angle1 = atan2(p1.y - center.y, p1.x - center.x)
            let angle2 = atan2(p2.y - center.y, p2.x - center.x)
            return angle1 < angle2
        }
    }

    /// Order vertices by angle from their centroid
    public static func orderCycleVertices(_ vertices: [CGPoint]) -> [CGPoint] {
        guard vertices.count >= 3 else { return vertices }

        let centroid = CGPoint(
            x: vertices.reduce(0) { $0 + $1.x } / CGFloat(vertices.count),
            y: vertices.reduce(0) { $0 + $1.y } / CGFloat(vertices.count)
        )

        return sortByAngle(points: vertices, center: centroid)
    }

    /// Check if two points are approximately equal within tolerance
    @available(*, deprecated, message: "Use CGPoint.isApproximatelyEqual(to:absoluteTolerance:) instead")
    public static func pointsEqual(_ p1: CGPoint, _ p2: CGPoint, tolerance: CGFloat = 1e-3) -> Bool {
        p1.isApproximatelyEqual(to: p2, absoluteTolerance: tolerance)
    }

    /// Check if a point lies on a line segment within tolerance
    @available(*, deprecated, message: "Use LineSegment.contains(_:within:) instead")
    public static func pointOnSegment(_ point: CGPoint, _ segment: LineSegment, tolerance: CGFloat = 1e-1) -> Bool {
        segment.contains(point, within: tolerance)
    }

    /// Check if segments are connected (share an endpoint)
    @available(*, deprecated, message: "Use LineSegment.sharesVertex(with:absoluteTolerance:) instead")
    public static func segmentsConnected(_ s1: LineSegment, _ s2: LineSegment, tolerance: CGFloat = 1e-3) -> Bool {
        s1.sharesVertex(with: s2, absoluteTolerance: tolerance)
    }
}
