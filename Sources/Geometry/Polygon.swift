#if canImport(CoreGraphics)
import CoreGraphics
#else
import Foundation
#endif

public struct Polygon {
    public var vertices: [CGPoint] {
        willSet {
            assert(vertices.count >= 3, "A polygon must have at least 3 vertices")
        }
    }

    public init(_ vertices: [CGPoint]) {
        // TODO: Sanity check
        assert(vertices.count >= 3, "A polygon must have at least 3 vertices")
        self.vertices = vertices
    }
}

extension Polygon: Equatable {
}

extension Polygon: Hashable {
}

extension Polygon: Sendable {
}

// An ugly alias to help with name collisions
public typealias Polygon_ = Polygon

public extension Polygon {
    static var empty: Self {
        Polygon([])
    }
}

public extension Polygon {
    /// Returns `true` if the polygon is simple (does not intersect itself).
    func isSimple(epsilon: CGFloat = 1e-5) -> Bool {
        guard vertices.count >= 3 else { return false }
        for i in 0..<vertices.count {
            let a1 = vertices[i]
            let a2 = vertices[(i + 1) % vertices.count]
            for j in (i + 1)..<vertices.count {
                if abs(i - j) <= 1 || (i == 0 && j == vertices.count - 1) {
                    continue
                }
                let b1 = vertices[j]
                let b2 = vertices[(j + 1) % vertices.count]
                if LineSegment(a1, a2).intersects(LineSegment(b1, b2), epsilon: epsilon) {
                    return false
                }
            }
        }
        return true
    }

    /// Returns `true` if the polygon is convex (all interior angles < 180°).
    var isConvex: Bool {
        guard vertices.count >= 3 else { return false }

        var initialSign: Bool?
        for i in 0..<vertices.count {
            let a = vertices[i]
            let b = vertices[(i + 1) % vertices.count]
            let c = vertices[(i + 2) % vertices.count]

            let cross = CGPoint.cross(a, b, c)

            if cross != 0 {
                let currentSign = cross > 0
                if let sign = initialSign {
                    if sign != currentSign {
                        return false
                    }
                } else {
                    initialSign = currentSign
                }
            }
        }

        return true
    }
}

public extension Polygon {
    /// The signed area of the polygon using the shoelace formula.
    /// For simple polygons, a positive area indicates counter-clockwise winding.
    var simpleArea: CGFloat {
        guard vertices.count >= 3 else { return 0 }

        var sum: CGFloat = 0
        for i in 0..<vertices.count {
            let current = vertices[i]
            let next = vertices[(i + 1) % vertices.count]
            sum += (current.x * next.y) - (next.x * current.y)
        }

        return sum / 2
    }
    
    /// Alias for simpleArea to match the removed GeometryNew code
    var signedArea: CGFloat {
        simpleArea
    }
}

public extension Polygon {
    var segments: [LineSegment] {
        guard vertices.count >= 2 else { return [] }
        return (0..<vertices.count).map { i in
            LineSegment(vertices[i], vertices[(i + 1) % vertices.count])
        }
    }
}
