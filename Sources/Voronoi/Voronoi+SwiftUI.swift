import SwiftUI
import Geometry

// MARK: - Triangle Path

public extension Path {
    init(_ triangle: Triangle) {
        self.init { path in
            path.move(to: triangle.a)
            path.addLine(to: triangle.b)
            path.addLine(to: triangle.c)
            path.closeSubpath()
        }
    }
}

// MARK: - VoronoiEdge Path

public extension Path {
    /// Creates a path from a Voronoi edge.
    /// For rays, the path extends to `maxRayLength` from the origin.
    init(_ edge: VoronoiEdge, maxRayLength: CGFloat = 1000) {
        switch edge.kind {
        case .segment(let segment):
            self.init { path in
                path.move(to: segment.start)
                path.addLine(to: segment.end)
            }
        case .ray(let ray):
            let normalized = ray.direction.normalized
            let end = CGPoint(
                x: ray.origin.x + normalized.dx * maxRayLength,
                y: ray.origin.y + normalized.dy * maxRayLength
            )
            self.init { path in
                path.move(to: ray.origin)
                path.addLine(to: end)
            }
        }
    }
}

// MARK: - LineSegment from Ray

public extension LineSegment {
    /// Creates a line segment from a ray with a specified maximum length.
    init(ray: Ray, maxLength: CGFloat) {
        let normalized = ray.direction.normalized
        let end = CGPoint(
            x: ray.origin.x + normalized.dx * maxLength,
            y: ray.origin.y + normalized.dy * maxLength
        )
        self.init(start: ray.origin, end: end)
    }
}
