import SwiftUI


public extension Path {
    
    init(segments: [LineSegment]) {
        self = Path { path in
            for segment in segments {
                path.move(to: segment.start)
                path.addLine(to: segment.end)
            }
        }
    }
    
    init(_ ray: Ray, within bounds: CGRect) {
        self.init()
        
        // Treat the ray as a parametric line: origin + t * direction, t ≥ 0
        // We need to find the smallest t > 0 such that the point is outside the bounds
        // Then we can draw a line from origin to that intersection
        
        guard let end = ray.intersection(with: bounds) else {
            // If the ray doesn't intersect the rect, draw nothing
            return
        }
        
        move(to: ray.origin)
        addLine(to: end)
    }
}

// MARK: - CGRect Conformance

extension CGRect: PathRepresentable {
    public func makePath() -> Path {
        Path(self)
    }
}

// MARK: - LineSegment Conformance

extension LineSegment: PathRepresentable {
    public func makePath() -> Path {
        var path = Path()
        path.move(to: start)
        path.addLine(to: end)
        return path
    }
}

// MARK: - Polygon Conformance

extension Polygon: PathRepresentable {
    public func makePath() -> Path {
        var path = Path()
        guard let first = vertices.first else { return path }

        path.move(to: first)
        for vertex in vertices.dropFirst() {
            path.addLine(to: vertex)
        }
        path.closeSubpath()
        return path
    }
}

extension Circle: PathRepresentable {
    public func makePath() -> Path {
        let path = Path(ellipseIn: CGRect(
            center: center, radius: radius
        ))
        return path
    }
}

// MARK: - Line PathRepresentable

extension Line: PathRepresentable {
    public func makePath() -> Path {
        var path = Path()
        
        let unit = direction.normalized
        let far: CGFloat = 1_000_000
        
        let p1 = point - unit * far
        let p2 = point + unit * far
        
        path.move(to: p1)
        path.addLine(to: p2)
        return path
    }
}

// MARK: - Ray PathRepresentable

extension Ray: PathRepresentable {
    public func makePath() -> Path {
        var path = Path()
        path.move(to: origin)
        path.addLine(to: point(at: 1_000_000)) // Arbitrary large distance for infinite ray
        return path
    }
}

// MARK: - CappedLineSegment PathRepresentable

extension CappedLineSegment: PathRepresentable {
    public func makePath() -> Path {
        return polygon.makePath()
    }
}
