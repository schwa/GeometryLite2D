import CoreGraphics

public struct LineSegment: Equatable, Hashable, Sendable {
    public var start: CGPoint
    public var end: CGPoint

    public init(_ start: CGPoint, _ end: CGPoint) {
        self.start = start
        self.end = end
    }
}

// MARK: - Core Properties

public extension LineSegment {
    // TODO: Deprecate and use start
    var a: CGPoint { start }
    // TODO: Deprecate and use end
    var b: CGPoint { end }
    
    /// Returns the midpoint of the line segment
    var midpoint: CGPoint {
        CGPoint(
            x: (start.x + end.x) / 2,
            y: (start.y + end.y) / 2
        )
    }
}

// MARK: - Contains Methods

public extension LineSegment {
    /// Checks if a point lies on this line segment
    func contains(_ point: CGPoint, tolerance: CGFloat = 0.01) -> Bool {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let lengthSquared = dx * dx + dy * dy
        
        if lengthSquared < tolerance * tolerance {
            // Degenerate segment - check distance to start point
            let dist = sqrt((point.x - start.x) * (point.x - start.x) + (point.y - start.y) * (point.y - start.y))
            return dist < tolerance
        }
        
        // Parameter t for the projection of point onto the line
        let t = ((point.x - start.x) * dx + (point.y - start.y) * dy) / lengthSquared
        
        // Check if projection is within segment bounds
        if t < 0.0 || t > 1.0 {
            // Point projects outside the segment, check distance to endpoints
            let distToStart = sqrt((point.x - start.x) * (point.x - start.x) + (point.y - start.y) * (point.y - start.y))
            let distToEnd = sqrt((point.x - end.x) * (point.x - end.x) + (point.y - end.y) * (point.y - end.y))
            return min(distToStart, distToEnd) < tolerance
        }
        
        // Point projects onto the segment, check perpendicular distance
        let projX = start.x + t * dx
        let projY = start.y + t * dy
        let dist = sqrt((point.x - projX) * (point.x - projX) + (point.y - projY) * (point.y - projY))
        return dist < tolerance
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

// MARK: - Intersection Methods

public extension LineSegment {
    func intersects(_ other: LineSegment) -> Bool {
        let d1 = direction(start, end, other.start)
        let d2 = direction(start, end, other.end)
        let d3 = direction(other.start, other.end, start)
        let d4 = direction(other.start, other.end, end)
        
        if ((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
           ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0)) {
            return true
        }
        
        if d1 == 0 && onSegment(start, other.start, end) { return true }
        if d2 == 0 && onSegment(start, other.end, end) { return true }
        if d3 == 0 && onSegment(other.start, start, other.end) { return true }
        if d4 == 0 && onSegment(other.start, end, other.end) { return true }
        
        return false
    }
    
    /// Check if this line segment intersects with another line segment
    func intersects(with other: LineSegment) -> Bool {
        let d = (start.x - end.x) * (other.start.y - other.end.y) - (start.y - end.y) * (other.start.x - other.end.x)
        if abs(d) < 0.0001 { return false }
        
        let t = ((start.x - other.start.x) * (other.start.y - other.end.y) - (start.y - other.start.y) * (other.start.x - other.end.x)) / d
        let u = -((start.x - end.x) * (start.y - other.start.y) - (start.y - end.y) * (start.x - other.start.x)) / d
        
        return t >= 0 && t <= 1 && u >= 0 && u <= 1
    }
    
    func intersection(_ other: LineSegment) -> CGPoint? {
        let x1 = start.x, y1 = start.y
        let x2 = end.x, y2 = end.y
        let x3 = other.start.x, y3 = other.start.y
        let x4 = other.end.x, y4 = other.end.y
        
        let denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
        
        if abs(denom) < 1e-10 {
            return nil
        }
        
        let t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denom
        let u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / denom
        
        if t >= 0 && t <= 1 && u >= 0 && u <= 1 {
            let x = x1 + t * (x2 - x1)
            let y = y1 + t * (y2 - y1)
            return CGPoint(x: x, y: y)
        }
        
        return nil
    }
    
    /// Check if this line segment intersects with a rectangle
    func intersects(rect: CGRect) -> Bool {
        // Check if either endpoint is inside the rectangle
        if rect.contains(start) || rect.contains(end) {
            return true
        }
        
        // Check if line segment intersects any of the four edges
        let topLeft = CGPoint(x: rect.minX, y: rect.minY)
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        
        let topEdge = LineSegment(topLeft, topRight)
        let rightEdge = LineSegment(topRight, bottomRight)
        let bottomEdge = LineSegment(bottomRight, bottomLeft)
        let leftEdge = LineSegment(bottomLeft, topLeft)
        
        return intersects(with: topEdge) ||
               intersects(with: rightEdge) ||
               intersects(with: bottomEdge) ||
               intersects(with: leftEdge)
    }
    
    /// Check if this segment overlaps with another segment (collinear and share points)
    func overlaps(with other: LineSegment, tolerance: CGFloat = 0.5) -> Bool {
        let thisStartOnOther = GeometryUtils.pointOnSegment(start, other, tolerance: tolerance)
        let thisEndOnOther = GeometryUtils.pointOnSegment(end, other, tolerance: tolerance)
        
        let otherStartOnThis = GeometryUtils.pointOnSegment(other.start, self, tolerance: tolerance)
        let otherEndOnThis = GeometryUtils.pointOnSegment(other.end, self, tolerance: tolerance)
        
        // If either segment is fully contained in the other, they overlap
        return (thisStartOnOther && thisEndOnOther) || (otherStartOnThis && otherEndOnThis)
    }
    
    // Private helper methods
    private func direction(_ p: CGPoint, _ q: CGPoint, _ r: CGPoint) -> CGFloat {
        return (q.x - p.x) * (r.y - p.y) - (q.y - p.y) * (r.x - p.x)
    }
    
    private func onSegment(_ p: CGPoint, _ q: CGPoint, _ r: CGPoint) -> Bool {
        return q.x <= max(p.x, r.x) && q.x >= min(p.x, r.x) &&
               q.y <= max(p.y, r.y) && q.y >= min(p.y, r.y)
    }
}

