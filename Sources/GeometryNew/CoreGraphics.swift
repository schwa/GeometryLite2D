import CoreGraphics

// MARK: - Core CGPoint Extensions

public extension CGPoint {
    /// Multiply a point by a scalar
    static func * (point: CGPoint, scale: CGFloat) -> CGPoint {
        return CGPoint(x: point.x * scale, y: point.y * scale)
    }
    
    /// Calculate the distance from this point to another point
    func distance(to other: CGPoint) -> CGFloat {
        return sqrt(pow(x - other.x, 2) + pow(y - other.y, 2))
    }
    
    /// Calculate the angle from this point to another point
    func angle(to other: CGPoint) -> CGFloat {
        return atan2(other.y - y, other.x - x)
    }
    
    /// Calculate the distance from this point to a line segment
    func distance(to segment: LineSegment) -> CGFloat {
        let dx = segment.end.x - segment.start.x
        let dy = segment.end.y - segment.start.y
        let lengthSquared = dx * dx + dy * dy
        
        if lengthSquared == 0 {
            return distance(to: segment.start)
        }
        
        let t = max(0, min(1, ((x - segment.start.x) * dx + (y - segment.start.y) * dy) / lengthSquared))
        let projection = CGPoint(x: segment.start.x + t * dx, y: segment.start.y + t * dy)
        
        return distance(to: projection)
    }
}

// MARK: - CGPoint Array Literal Support

extension CGPoint: @retroactive ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: CGFloat...) {
        precondition(elements.count == 2, "CGPoint array literal must contain exactly 2 elements")
        self.init(x: elements[0], y: elements[1])
    }
}