import CoreGraphics

// MARK: - Segment Polygon Relation

public enum SegmentPolygonRelation {
    case fullyInside
    case partiallyInside([LineSegment])
    case outside
}

// MARK: - New Polygon functionality from GeometryNew

public extension Polygon {
    /// The signed area of the polygon
    var signedArea: CGFloat {
        guard vertices.count >= 3 else { return 0 }
        var acc: CGFloat = 0
        for i in 0..<vertices.count {
            let p = vertices[i], q = vertices[(i + 1) % vertices.count]
            acc += p.x * q.y - q.x * p.y
        }
        return 0.5 * acc
    }

    /// Checks if a line segment is contained within or on the boundary of the polygon
    func contains(_ segment: LineSegment) -> Bool {
        // Fast path: Check if this segment is exactly one of the polygon's edges
        let edges = segments
        for edge in edges {
            // Check both directions since segments might be oriented differently
            if (GeometryUtils.pointsEqual(segment.start, edge.start) &&
                    GeometryUtils.pointsEqual(segment.end, edge.end)) ||
                (GeometryUtils.pointsEqual(segment.start, edge.end) &&
                    GeometryUtils.pointsEqual(segment.end, edge.start)) {
                // This segment IS a polygon edge - consider it on boundary, not inside
                return false
            }
        }

        // Check if segment lies on any polygon edge (collinear case)
        // This handles partial edges and segments that run along the boundary
        for edge in edges {
            // Check if both endpoints of segment lie on this edge
            if edge.contains(segment.start) && edge.contains(segment.end) {
                // Segment lies on the polygon boundary
                return false
            }
        }

        // Check boundary status of endpoints
        let startOnBoundary = edges.contains { edge in
            edge.contains(segment.start)
        }
        let endOnBoundary = edges.contains { edge in
            edge.contains(segment.end)
        }

        // If either endpoint is on the boundary, consider it not contained
        // (segments touching the boundary are typically walls, not interior segments)
        if startOnBoundary || endOnBoundary {
            return false
        }

        // Robust algorithm:
        // 1. Check if either endpoint is strictly outside (not on boundary)
        let startInside = contains(segment.start) || startOnBoundary
        let endInside = contains(segment.end) || endOnBoundary

        if !startInside || !endInside {
            return false  // At least one endpoint is outside
        }

        // 2. Check for intersection with polygon edges
        for edge in edges {
            // Check if segment intersects this edge
            if let intersection = segment.intersection(edge) {
                // Check if intersection is at a shared vertex
                let isSharedVertex = GeometryUtils.pointsEqual(intersection, segment.start) ||
                    GeometryUtils.pointsEqual(intersection, segment.end) ||
                    GeometryUtils.pointsEqual(intersection, edge.start) ||
                    GeometryUtils.pointsEqual(intersection, edge.end)

                if !isSharedVertex {
                    // Segment crosses the polygon boundary at a non-vertex point
                    return false
                }
            }
        }

        // 3. Both endpoints are inside and no problematic intersections
        return true
    }

    /// Finds all intersection points with a line segment
    func intersections(with segment: LineSegment) -> [CGPoint] {
        var intersections: [CGPoint] = []

        for i in 0..<vertices.count {
            let j = (i + 1) % vertices.count
            let edge = LineSegment(vertices[i], vertices[j])

            if let intersection = segment.intersection(edge) {
                intersections.append(intersection)
            }
        }

        return intersections
    }

    /// Classifies how a segment relates to this polygon
    func classify(_ segment: LineSegment) -> SegmentPolygonRelation {
        let startInside = contains(segment.start)
        let endInside = contains(segment.end)

        if startInside && endInside {
            return .fullyInside
        }

        var intersectionPoints: [CGPoint] = []

        if startInside {
            intersectionPoints.append(segment.start)
        }
        if endInside {
            intersectionPoints.append(segment.end)
        }

        // Add polygon edge intersections
        let edgeIntersections = intersections(with: segment)
        intersectionPoints.append(contentsOf: edgeIntersections)

        if intersectionPoints.isEmpty {
            return .outside
        }

        // Sort intersection points by distance from segment start
        intersectionPoints.sort { p1, p2 in
            let dist1 = segment.start.distance(to: p1)
            let dist2 = segment.start.distance(to: p2)
            return dist1 < dist2
        }

        // Build partial segments that are inside the polygon
        var partialSegments: [LineSegment] = []

        if startInside && intersectionPoints.count > 1 {
            partialSegments.append(LineSegment(intersectionPoints[0], intersectionPoints[1]))
        } else if endInside && intersectionPoints.count > 1 {
            let lastIdx = intersectionPoints.count - 1
            partialSegments.append(LineSegment(intersectionPoints[lastIdx - 1], intersectionPoints[lastIdx]))
        } else if !startInside && !endInside && intersectionPoints.count >= 2 {
            var i = 0
            while i < intersectionPoints.count - 1 {
                let midPoint = CGPoint(
                    x: (intersectionPoints[i].x + intersectionPoints[i + 1].x) / 2,
                    y: (intersectionPoints[i].y + intersectionPoints[i + 1].y) / 2
                )
                if contains(midPoint) {
                    partialSegments.append(LineSegment(intersectionPoints[i], intersectionPoints[i + 1]))
                }
                i += 1
            }
        }

        return partialSegments.isEmpty ? .outside : .partiallyInside(partialSegments)
    }

    /// Normalize the polygon to ensure consistent winding order (counter-clockwise)
    mutating func normalize() {
        guard vertices.count >= 3 else { return }

        // Calculate the signed area to determine winding order
        var signedArea: CGFloat = 0
        for i in 0..<vertices.count {
            let j = (i + 1) % vertices.count
            signedArea += vertices[i].x * vertices[j].y
            signedArea -= vertices[j].x * vertices[i].y
        }

        // If area is negative, vertices are clockwise, so reverse them
        if signedArea < 0 {
            vertices.reverse()
        }
    }

    /// Returns a normalized copy of the polygon
    func normalized() -> Polygon {
        var copy = self
        copy.normalize()
        return copy
    }
}
