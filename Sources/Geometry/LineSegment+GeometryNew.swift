import CoreGraphics

// MARK: - New LineSegment functionality from GeometryNew

public extension LineSegment {
    /// Returns the vertices of the line segment as an array
    var vertices: [CGPoint] {
        [start, end]
    }
    
    /// Scales the line segment from its center by the given factor
    func centerScale(_ scale: CGFloat) -> LineSegment {
        let center = CGPoint(
            x: (start.x + end.x) / 2,
            y: (start.y + end.y) / 2
        )

        let newStart = CGPoint(
            x: center.x + (start.x - center.x) * scale,
            y: center.y + (start.y - center.y) * scale
        )

        let newEnd = CGPoint(
            x: center.x + (end.x - center.x) * scale,
            y: center.y + (end.y - center.y) * scale
        )

        return LineSegment(newStart, newEnd)
    }
    
    /// Returns the midpoint of the line segment
    var midpoint: CGPoint {
        CGPoint(
            x: (start.x + end.x) / 2,
            y: (start.y + end.y) / 2
        )
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
        
        return intersects(topEdge) ||
               intersects(rightEdge) ||
               intersects(bottomEdge) ||
               intersects(leftEdge)
    }
    
    /// Returns the intersection point between two line segments, if any
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
    
    /// Check if this segment overlaps with another segment (collinear and share points)
    func overlaps(with other: LineSegment, tolerance: CGFloat = 0.5) -> Bool {
        let thisStartOnOther = GeometryUtils.pointOnSegment(start, other, tolerance: tolerance)
        let thisEndOnOther = GeometryUtils.pointOnSegment(end, other, tolerance: tolerance)
        
        let otherStartOnThis = GeometryUtils.pointOnSegment(other.start, self, tolerance: tolerance)
        let otherEndOnThis = GeometryUtils.pointOnSegment(other.end, self, tolerance: tolerance)
        
        // If either segment is fully contained in the other, they overlap
        return (thisStartOnOther && thisEndOnOther) || (otherStartOnThis && otherEndOnThis)
    }
}