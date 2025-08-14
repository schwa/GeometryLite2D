import Foundation
import CoreGraphics

// MARK: - Geometry Utilities

public struct GeometryUtils {
    /// Sort points by angle from a central point
    public static func sortByAngle(points: [CGPoint], center: CGPoint) -> [CGPoint] {
        return points.sorted { p1, p2 in
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
    public static func pointsEqual(_ p1: CGPoint, _ p2: CGPoint, tolerance: CGFloat = 0.001) -> Bool {
        return abs(p1.x - p2.x) < tolerance && abs(p1.y - p2.y) < tolerance
    }
    
    /// Check if a point lies on a line segment within tolerance
    public static func pointOnSegment(_ point: CGPoint, _ segment: LineSegment, tolerance: CGFloat = 0.5) -> Bool {
        let minX = min(segment.start.x, segment.end.x) - tolerance
        let maxX = max(segment.start.x, segment.end.x) + tolerance
        let minY = min(segment.start.y, segment.end.y) - tolerance
        let maxY = max(segment.start.y, segment.end.y) + tolerance
        
        if point.x < minX || point.x > maxX || point.y < minY || point.y > maxY {
            return false
        }
        
        // Check distance from point to line
        let lineVec = CGPoint(x: segment.end.x - segment.start.x, y: segment.end.y - segment.start.y)
        let pointVec = CGPoint(x: point.x - segment.start.x, y: point.y - segment.start.y)
        let lineLen = sqrt(lineVec.x * lineVec.x + lineVec.y * lineVec.y)
        
        if lineLen < 0.001 { return false }
        
        let t = max(0, min(1, (pointVec.x * lineVec.x + pointVec.y * lineVec.y) / (lineLen * lineLen)))
        let projection = CGPoint(x: segment.start.x + t * lineVec.x, y: segment.start.y + t * lineVec.y)
        let distance = sqrt(pow(point.x - projection.x, 2) + pow(point.y - projection.y, 2))
        
        return distance <= tolerance
    }
    
    /// Check if segments are connected (share an endpoint)
    public static func segmentsConnected(_ s1: LineSegment, _ s2: LineSegment, tolerance: CGFloat = 0.001) -> Bool {
        return pointsEqual(s1.start, s2.start, tolerance: tolerance) ||
               pointsEqual(s1.start, s2.end, tolerance: tolerance) ||
               pointsEqual(s1.end, s2.start, tolerance: tolerance) ||
               pointsEqual(s1.end, s2.end, tolerance: tolerance)
    }
}