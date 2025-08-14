import CoreGraphics

public func convexHull(_ points: [CGPoint]) -> [CGPoint] {
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
