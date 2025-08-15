import CoreGraphics
import SwiftUI

// TODO: Replace all this with PathRepresentable 

public extension Path {
    init(_ circle: Circle) {
        self.init(ellipseIn: .init(center: circle.center, radius: circle.radius))
    }
}

// MARK: -

public extension Path {
    init(_ line: Line) {
        self.init()

        let unit = line.direction.normalized
        let far: CGFloat = 1_000_000

        let p1 = line.point - unit * far
        let p2 = line.point + unit * far

        self.move(to: p1)
        self.addLine(to: p2)
    }
}

// MARK: -

public extension Path {
    init(_ segment: LineSegment) {
        self = Path { path in
            path.move(to: segment.start)
            path.addLine(to: segment.end)
        }
    }
}

public extension Path {
    init(segments: [LineSegment]) {
        self = Path { path in
            for segment in segments {
                path.move(to: segment.start)
                path.addLine(to: segment.end)
            }
        }
    }
}

// MARK: -

public extension Path {
    init(_ polygon: Polygon) {
        self = Path { path in
            guard let (first, rest) = polygon.vertices.uncons() else {
                return
            }
            path.move(to: first)
            for point in rest {
                path.addLine(to: point)
            }
            path.closeSubpath()
        }
    }
}

// MARK: -

public extension Path {
    init(_ ray: Ray) {
        self.init()
        move(to: ray.origin)
        addLine(to: ray.point(at: 1_000_000)) // Arbitrary large distance for infinite ray
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

public extension Path {
    init(_ segment: CappedLineSegment) {
        self = Path(segment.polygon)
    }
}

