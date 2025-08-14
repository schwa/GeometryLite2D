import CoreGraphics
import Foundation

// MARK: - Segment Intersection

public enum SegmentIntersection {
    case none
    /// Intersection at a single point. t1/t2 are parameters along s1/s2 in [0,1].
    case point(p: CGPoint, t1: CGFloat, t2: CGFloat)
    // If you *do* want to handle collinear overlaps later, add another case.
}

/// Computes the intersection between two line segments, returning the intersection point and parameters
public func segmentIntersection(_ s1: LineSegment, _ s2: LineSegment) -> SegmentIntersection {
    let x1 = s1.start.x, y1 = s1.start.y
    let x2 = s1.end.x, y2 = s1.end.y
    let x3 = s2.start.x, y3 = s2.start.y
    let x4 = s2.end.x, y4 = s2.end.y

    let denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)

    if abs(denom) < 1e-10 {
        return .none  // Parallel or collinear
    }

    let t1 = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denom
    let t2 = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / denom

    if t1 >= 0 && t1 <= 1 && t2 >= 0 && t2 <= 1 {
        let x = x1 + t1 * (x2 - x1)
        let y = y1 + t1 * (y2 - y1)
        return .point(p: CGPoint(x: x, y: y), t1: t1, t2: t2)
    }

    return .none
}

// MARK: - Geometry Helpers

public func angle(from p: CGPoint, to q: CGPoint) -> CGFloat {
    atan2(q.y - p.y, q.x - p.x)
}

public func signedArea(of verts: [CGPoint], loop: [Int]) -> CGFloat {
    var a: CGFloat = 0
    let n = loop.count
    guard n >= 3 else { return 0 }
    for i in 0..<n {
        let p = verts[loop[i]]
        let q = verts[loop[(i + 1) % n]]
        a += p.x * q.y - q.x * p.y
    }
    return 0.5 * a
}
