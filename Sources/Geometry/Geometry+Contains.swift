import CoreGraphics

// MARK: - LineSegment

public extension LineSegment {
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
    
    func contains(_ point: CGPoint, interior: Bool, epsilon: CGFloat = 1e-5) -> Bool {
        contains(point, epsilon: epsilon) && (!interior || (point != start && point != end))
    }
    
    func contains(_ point: CGPoint, within radius: CGFloat) -> Bool {
        let lineVec = end - start
        let pointVec = point - start
        let lineLengthSq = lineVec.lengthSquared
        if lineLengthSq == 0 {
            return (start - point).length <= radius
        }
        let t = max(0, min(1, pointVec.dot(lineVec) / lineLengthSq))
        let projection = start + lineVec * t
        return (projection - point).length <= radius
    }
    
    /// Checks if this line segment contains another line segment
    /// A segment contains another if the other lies entirely on this segment
    func contains(_ other: LineSegment) -> Bool {
        // Check if both endpoints of 'other' lie on 'this' segment
        let tolerance: CGFloat = 0.01
        
        // First check if the segments are collinear
        let thisVec = CGPoint(x: end.x - start.x, y: end.y - start.y)
        let otherStartVec = CGPoint(x: other.start.x - start.x, y: other.start.y - start.y)
        let otherEndVec = CGPoint(x: other.end.x - start.x, y: other.end.y - start.y)
        
        // Cross product should be near zero for collinear points
        let cross1 = thisVec.x * otherStartVec.y - thisVec.y * otherStartVec.x
        let cross2 = thisVec.x * otherEndVec.y - thisVec.y * otherEndVec.x
        
        if abs(cross1) > tolerance || abs(cross2) > tolerance {
            return false // Not collinear
        }
        
        // Check if both endpoints are within the segment bounds
        let thisLength = sqrt(thisVec.x * thisVec.x + thisVec.y * thisVec.y)
        if thisLength < tolerance {
            // Degenerate segment
            return false
        }
        
        // Project other's endpoints onto this segment
        let t1 = (otherStartVec.x * thisVec.x + otherStartVec.y * thisVec.y) / (thisLength * thisLength)
        let t2 = (otherEndVec.x * thisVec.x + otherEndVec.y * thisVec.y) / (thisLength * thisLength)
        
        // Both projections must be within [0, 1] to be contained
        return t1 >= -tolerance && t1 <= 1 + tolerance &&
            t2 >= -tolerance && t2 <= 1 + tolerance
    }
}

// MARK: - Ray

public extension Ray {
    func contains(_ point: CGPoint, tolerance: CGFloat = 1e-6) -> Bool {
        let toPoint = CGVector(dx: point.x - origin.x, dy: point.y - origin.y)
        let cross = direction.dx * toPoint.dy - direction.dy * toPoint.dx
        if abs(cross) > tolerance {
            return false
        }
        let dot = direction.dx * toPoint.dx + direction.dy * toPoint.dy
        return dot >= -tolerance  // Allow for minor floating-point underflow
    }
}

// MARK: - Line

public extension Line {
    func contains(_ test: CGPoint, tolerance: CGFloat = 1e-6) -> Bool {
        let dx = test.x - point.x
        let dy = test.y - point.y
        let cross = dx * direction.dy - dy * direction.dx
        return abs(cross) <= tolerance
    }
}

// MARK: - Polygon

public extension Polygon {
    func contains(_ point: CGPoint) -> Bool {
        var count = 0
        let n = vertices.count
        guard n >= 3 else { return false }

        for i in 0..<n {
            let a = vertices[i]
            let b = vertices[(i + 1) % n]

            // Check if point is on the edge
            if pointIsOnLineSegment(point, a, b) {
                return true
            }

            // Ray-casting: check if the edge crosses a horizontal ray rightward from `point`
            let minY = min(a.y, b.y)
            let maxY = max(a.y, b.y)
            if point.y > minY && point.y <= maxY && point.x <= max(a.x, b.x) {
                let xinters = (point.y - a.y) * (b.x - a.x) / (b.y - a.y + CGFloat.ulpOfOne) + a.x
                if point.x < xinters {
                    count += 1
                }
            }
        }
        return count % 2 == 1
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
            if edge.contains(segment.start, epsilon: 1e-5) && edge.contains(segment.end, epsilon: 1e-5) {
                // Segment lies on the polygon boundary
                return false
            }
        }
        
        // Check boundary status of endpoints
        let startOnBoundary = edges.contains { edge in
            edge.contains(segment.start, epsilon: 1e-5)
        }
        let endOnBoundary = edges.contains { edge in
            edge.contains(segment.end, epsilon: 1e-5)
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
    
    private func pointIsOnLineSegment(_ p: CGPoint, _ a: CGPoint, _ b: CGPoint) -> Bool {
        let cross = (b.y - a.y) * (p.x - a.x) - (b.x - a.x) * (p.y - a.y)
        if abs(cross) > CGFloat.ulpOfOne {
            return false
        }

        let dot = (p.x - a.x) * (b.x - a.x) + (p.y - a.y) * (b.y - a.y)
        if dot < 0 {
            return false
        }

        let squaredLengthBA = (b.x - a.x) * (b.x - a.x) + (b.y - a.y) * (b.y - a.y)
        if dot > squaredLengthBA {
            return false
        }

        return true
    }
}
