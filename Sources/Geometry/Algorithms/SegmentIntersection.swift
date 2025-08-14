import CoreGraphics
import Foundation
import Numerics

// MARK: - Deprecated functions

/// Computes the intersection between two line segments, returning the intersection point and parameters
@available(*, deprecated, message: "Use LineSegment.segmentIntersection(with:absoluteTolerance:) instead")
public func segmentIntersection(_ s1: LineSegment, _ s2: LineSegment, absoluteTolerance: CGFloat = 1e-10) -> SegmentIntersection {
    s1.segmentIntersection(with: s2, absoluteTolerance: absoluteTolerance)
}

// MARK: - Geometry Helpers

// TODO: Move
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
