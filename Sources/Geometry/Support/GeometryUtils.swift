import CoreGraphics
import Foundation

// TODO: Deprecate GeometryUtils and put functions somewhere else
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
}
