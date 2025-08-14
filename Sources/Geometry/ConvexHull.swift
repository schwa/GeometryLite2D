import CoreGraphics

/// Computes the convex hull using the default algorithm (Andrew's monotone chain)
public func convexHull(_ points: [CGPoint]) -> [CGPoint] {
    convexHullAndrewMonotoneChain(points)
}

/// Computes the convex hull using Andrew's monotone chain algorithm
public func convexHullAndrewMonotoneChain(_ points: [CGPoint]) -> [CGPoint] {
    guard points.count > 2 else { return points }
    let sortedPoints = points.sorted {
        $0.x == $1.x ? $0.y < $1.y : $0.x < $1.x
    }
    var lower: [CGPoint] = []
    for point in sortedPoints {
        while lower.count >= 2 && CGPoint.cross(lower[lower.count - 2], lower[lower.count - 1], point) <= 0 {
            lower.removeLast()
        }
        lower.append(point)
    }
    var upper: [CGPoint] = []
    for point in sortedPoints.reversed() {
        while upper.count >= 2 && CGPoint.cross(upper[upper.count - 2], upper[upper.count - 1], point) <= 0 {
            upper.removeLast()
        }
        upper.append(point)
    }
    lower.removeLast()
    upper.removeLast()
    return lower + upper
}

/// Adjusts the order of points in a convex polygon to ensure they are arranged in a counter-clockwise direction.
///
/// This function takes an array of `CGPoint` representing the vertices of a convex polygon
/// and reorders them if necessary to maintain a consistent counter-clockwise winding order.
///
/// - Parameter points: An array of `CGPoint` representing the vertices of a convex polygon.
/// - Returns: A reordered array of `CGPoint` where the vertices are arranged in a counter-clockwise order.
public func untwistConvexPolygon(_ points: [CGPoint]) -> [CGPoint] {
    guard points.count > 2 else { return points }

    // 1. Compute the centroid
    let centroid = CGPoint(
        x: points.map(\.x).reduce(0, +) / CGFloat(points.count),
        y: points.map(\.y).reduce(0, +) / CGFloat(points.count)
    )

    // 2. Sort points by angle from the centroid
    return points.sorted { a, b in
        let angleA = atan2(a.y - centroid.y, a.x - centroid.x)
        let angleB = atan2(b.y - centroid.y, b.x - centroid.x)
        return angleA < angleB
    }
}

// MARK: - Graham Scan Algorithm

/// Computes the convex hull of a set of points using Graham's scan algorithm
/// - Parameter points: Array of points to compute hull for
/// - Returns: Array of points forming the convex hull in counter-clockwise order
public func convexHullGrahamScan(_ points: [CGPoint]) -> [CGPoint] {
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
            let cross = crossProductForHull(secondLast, last, point)
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

/// Helper function for Graham scan - computes the cross product of vectors OA and OB where O is the origin
/// - Returns: Positive if counter-clockwise turn, negative if clockwise, zero if collinear
private func crossProductForHull(_ o: CGPoint, _ a: CGPoint, _ b: CGPoint) -> CGFloat {
    return (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x)
}
