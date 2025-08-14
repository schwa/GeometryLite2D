import CoreGraphics

// MARK: - Convenience Initializers

public extension Line {
    init(p1: CGPoint, p2: CGPoint) {
        assert(p1 != p2, "Points must be distinct")
        let dir = CGVector(dx: p2.x - p1.x, dy: p2.y - p1.y)
        self.init(point: p1, direction: dir)
    }
    
    init(_ lineSegment: LineSegment) {
        self.init(p1: lineSegment.start, p2: lineSegment.end)
    }
    
    init(_ ray: Ray) {
        self.init(point: ray.origin, direction: ray.direction)
    }
}

// MARK: - Methods

public extension Line {
    func perpendicularThrough(_ p: CGPoint) -> Line {
        let perpDirection = CGVector(dx: -direction.dy, dy: direction.dx)
        return Line(point: p, direction: perpDirection)
    }
    
    func parallelTo(_ offset: CGFloat) -> Line {
        let unit = direction.normalized
        
        // Rotate 90° CCW to get the normal vector
        let normal = CGVector(dx: -unit.dy, dy: unit.dx)
        
        let offsetVector = CGVector(dx: normal.dx * offset, dy: normal.dy * offset)
        return Line(point: point + offsetVector, direction: direction)
    }
}