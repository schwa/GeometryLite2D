import CoreGraphics
import Foundation

// MARK: - Geometric Algorithms

// MARK: - Convex Hull (Graham Scan)

/// Computes the convex hull of a set of points using Graham's scan algorithm
/// - Parameter points: Array of points to compute hull for
/// - Returns: Array of points forming the convex hull in counter-clockwise order
public func convexHull(of points: [CGPoint]) -> [CGPoint] {
    guard points.count >= 3 else { return points }

    // Find the bottom-most point (or left-most if tied)
    let start = points.min { p1, p2 in
        if p1.y != p2.y { return p1.y < p2.y }
        return p1.x < p2.x
    }!

    // Sort points by polar angle relative to start point
    let sorted = points.filter { $0 != start }.sorted { p1, p2 in
        let angle1 = atan2(p1.y - start.y, p1.x - start.x)
        let angle2 = atan2(p2.y - start.y, p2.x - start.x)
        if abs(angle1 - angle2) < 1e-10 {
            // If angles are same, closer point comes first
            let dist1 = pow(p1.x - start.x, 2) + pow(p1.y - start.y, 2)
            let dist2 = pow(p2.x - start.x, 2) + pow(p2.y - start.y, 2)
            return dist1 < dist2
        }
        return angle1 < angle2
    }

    // Build the hull using a stack
    var hull = [start]

    for point in sorted {
        // Remove points that make a right turn
        while hull.count > 1 {
            let last = hull[hull.count - 1]
            let secondLast = hull[hull.count - 2]
            let cross = crossProduct(secondLast, last, point)
            if cross <= 0 {
                hull.removeLast()
            } else {
                break
            }
        }
        hull.append(point)
    }

    return hull
}

/// Computes the cross product of vectors OA and OB where O is the origin
/// - Returns: Positive if counter-clockwise turn, negative if clockwise, zero if collinear
public func crossProduct(_ o: CGPoint, _ a: CGPoint, _ b: CGPoint) -> CGFloat {
    (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x)
}

/// Cross product of two vectors (from origin)
public func crossProduct(_ v1: CGPoint, _ v2: CGPoint) -> CGFloat {
    v1.x * v2.y - v1.y * v2.x
}
