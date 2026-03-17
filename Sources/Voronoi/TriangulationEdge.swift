import CoreGraphics

/// An internal edge type used for Delaunay triangulation.
/// This is distinct from LineSegment to provide order-independent equality for triangulation algorithms.
public struct TriangulationEdge: Sendable {
    public var a: CGPoint
    public var b: CGPoint

    public init(a: CGPoint, b: CGPoint) {
        self.a = a
        self.b = b
    }
}

extension TriangulationEdge: Equatable {
    public static func == (lhs: TriangulationEdge, rhs: TriangulationEdge) -> Bool {
        let lhs = lhs.ordered
        let rhs = rhs.ordered
        return lhs.a == rhs.a && lhs.b == rhs.b
    }
}

extension TriangulationEdge: Hashable {
    public func hash(into hasher: inout Hasher) {
        let ordered = ordered
        hasher.combine(ordered.a.x)
        hasher.combine(ordered.a.y)
        hasher.combine(ordered.b.x)
        hasher.combine(ordered.b.y)
    }
}

public extension TriangulationEdge {
    var ordered: TriangulationEdge {
        let (first, second): (CGPoint, CGPoint)
        if a.x < b.x || (a.x == b.x && a.y <= b.y) {
            first = a
            second = b
        } else {
            first = b
            second = a
        }
        return TriangulationEdge(a: first, b: second)
    }
}
