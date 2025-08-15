import CoreGraphics
import Numerics

// TODO: This file needs a big ol' cleanup

// MARK: - Segment Intersection

public enum SegmentIntersection {
    case none
    /// Intersection at a single point. t1/t2 are parameters along s1/s2 in [0,1].
    case point(p: CGPoint, t1: CGFloat, t2: CGFloat)
    // If you *do* want to handle collinear overlaps later, add another case.
}

// MARK: Line

public extension Line {
    func intersection(with other: Line, absoluteTolerance: CGFloat = 1e-6) -> CGPoint? {
        let dx = other.point.x - point.x
        let dy = other.point.y - point.y

        let det = direction.dx * other.direction.dy - direction.dy * other.direction.dx
        if det.isApproximatelyEqual(to: 0, absoluteTolerance: absoluteTolerance) {
            return nil // lines are parallel
        }

        let t = (dx * other.direction.dy - dy * other.direction.dx) / det
        return CGPoint(x: point.x + t * direction.dx, y: point.y + t * direction.dy)
    }
}

// MARK: LineSegment

public extension LineSegment {
    /// Computes the intersection between this line segment and another, returning the intersection point and parameters
    func segmentIntersection(with other: LineSegment, absoluteTolerance: CGFloat = 1e-10) -> SegmentIntersection {
        let x1 = start.x, y1 = start.y
        let x2 = end.x, y2 = end.y
        let x3 = other.start.x, y3 = other.start.y
        let x4 = other.end.x, y4 = other.end.y

        let denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)

        if denom.isApproximatelyEqual(to: 0, absoluteTolerance: absoluteTolerance) {
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

    func intersects(_ lineSegment: LineSegment, absoluteTolerance: CGFloat = 1e-5) -> Bool {
        // First check using the centralized implementation
        switch segmentIntersection(with: lineSegment, absoluteTolerance: absoluteTolerance) {
        case .point:
            return true

        case .none:
            // The current segmentIntersection doesn't handle collinear overlaps
            // so we need to check for that case separately
            let p = start
            let q = lineSegment.start
            let r = end - start
            let s = lineSegment.end - lineSegment.start

            let rxs = r.cross(s)
            let qpxr = (q - p).cross(r)

            // Check if lines are collinear
            if rxs.isApproximatelyEqual(to: 0, absoluteTolerance: absoluteTolerance) &&
                qpxr.isApproximatelyEqual(to: 0, absoluteTolerance: absoluteTolerance) {
                // Check for overlap
                let t0 = (q - p).dot(r) / r.dot(r)
                let t1 = t0 + s.dot(r) / r.dot(r)
                return (t0 >= 0 && t0 <= 1) || (t1 >= 0 && t1 <= 1) || (t0 < 0 && t1 > 1) || (t1 < 0 && t0 > 1)
            }
            return false
        }
    }

    func intersection(_ ray: Ray, absoluteTolerance: CGFloat = 1e-5) -> CGPoint? {
        let p = ray.origin
        let r = ray.direction

        let q = start
        let s = end - start

        let rCrossS = r.dx * s.y - r.dy * s.x
        if rCrossS.isApproximatelyEqual(to: 0, absoluteTolerance: absoluteTolerance) {
            // Lines are parallel or colinear
            return nil
        }

        let qp = CGVector(dx: q.x - p.x, dy: q.y - p.y)
        let t = (qp.dx * s.y - qp.dy * s.x) / rCrossS
        let u = (qp.dx * r.dy - qp.dy * r.dx) / rCrossS

        // Ray: t >= 0, Segment: u in [0,1]
        if t >= -absoluteTolerance, u >= -absoluteTolerance, u <= 1 + absoluteTolerance {
            return CGPoint(x: p.x + t * r.dx, y: p.y + t * r.dy)
        }
        return nil
    }

    func intersects(_ rect: CGRect) -> Bool {
        rect.intersects(with: self)
    }

    /// Returns the intersection point between two line segments, if any
    func intersection(_ other: LineSegment, absoluteTolerance: CGFloat = 1e-10) -> CGPoint? {
        // Use the centralized implementation
        switch segmentIntersection(with: other, absoluteTolerance: absoluteTolerance) {
        case .none:
            return nil

        case let .point(p, _, _):
            return p
        }
    }

    /// Check if this segment overlaps with another segment (collinear and share points)
    func overlaps(_ other: LineSegment, radius: CGFloat = 1e-1) -> Bool {
        let thisStartOnOther = other.contains(start, within: radius)
        let thisEndOnOther = other.contains(end, within: radius)

        let otherStartOnThis = self.contains(other.start, within: radius)
        let otherEndOnThis = self.contains(other.end, within: radius)

        // If either segment is fully contained in the other, they overlap
        return (thisStartOnOther && thisEndOnOther) || (otherStartOnThis && otherEndOnThis)
    }
}

// MARK: -

public extension Ray {
    func intersection(with other: Ray, absoluteTolerance: CGFloat = 1e-6) -> CGPoint? {
        let dx = other.origin.x - origin.x
        let dy = other.origin.y - origin.y

        let det = direction.dx * other.direction.dy - direction.dy * other.direction.dx
        if det.isApproximatelyEqual(to: 0, absoluteTolerance: absoluteTolerance) {
            return nil // Parallel rays
        }

        // Solve for t in self.point(at: t)
        let t = (dx * other.direction.dy - dy * other.direction.dx) / det
        if t < -absoluteTolerance {
            return nil // Intersection is behind self
        }

        // Solve for u in other.point(at: u)
        let u = (dx * direction.dy - dy * direction.dx) / det
        if u < -absoluteTolerance {
            return nil // Intersection is behind other
        }

        return point(at: t)
    }
}

public extension Ray {
    func intersection(with segment: LineSegment) -> CGPoint? {
        let p = origin
        let r = direction

        let q = segment.start
        let s = segment.vector

        let rCrossS = r.cross(s)
        let qMinusP = q - p

        // If cross product is zero, lines are parallel (or colinear)
        if rCrossS.isApproximatelyEqual(to: 0, absoluteTolerance: .ulpOfOne) {
            return nil
        }

        let t = qMinusP.cross(CGPoint(s)) / rCrossS
        let u = qMinusP.cross(CGPoint(r)) / rCrossS

        // Check that the intersection lies on the ray (t >= 0) and within the segment (0 <= u <= 1)
        if t >= 0, u >= 0, u <= 1 {
            return p + r * t
        }

        return nil
    }

    func intersection(with rect: CGRect) -> CGPoint? {
        let edges: [LineSegment] = [
            LineSegment(start: CGPoint(x: rect.minX, y: rect.minY), end: CGPoint(x: rect.maxX, y: rect.minY)), // top
            LineSegment(start: CGPoint(x: rect.maxX, y: rect.minY), end: CGPoint(x: rect.maxX, y: rect.maxY)), // right
            LineSegment(start: CGPoint(x: rect.maxX, y: rect.maxY), end: CGPoint(x: rect.minX, y: rect.maxY)), // bottom
            LineSegment(start: CGPoint(x: rect.minX, y: rect.maxY), end: CGPoint(x: rect.minX, y: rect.minY))  // left
        ]

        var closest: (distance: CGFloat, point: CGPoint)?

        for edge in edges {
            if let intersection = self.intersection(with: edge) {
                let d = intersection.distance(to: origin)
                if closest == nil || d < closest!.distance {
                    closest = (d, intersection)
                }
            }
        }

        return closest?.point
    }
}

// MARK: -

public extension CGRect {
    func intersects(with lineSegment: LineSegment) -> Bool {
        // 1. If either point is inside the rect, the segment intersects
        if self.contains(lineSegment.start) || self.contains(lineSegment.end) {
            return true
        }

        // 2. Check intersection with each edge of the rect
        let top = LineSegment(start: CGPoint(x: minX, y: minY), end: CGPoint(x: maxX, y: minY))
        let bottom = LineSegment(start: CGPoint(x: minX, y: maxY), end: CGPoint(x: maxX, y: maxY))
        let left = LineSegment(start: CGPoint(x: minX, y: minY), end: CGPoint(x: minX, y: maxY))
        let right = LineSegment(start: CGPoint(x: maxX, y: minY), end: CGPoint(x: maxX, y: maxY))

        return lineSegment.intersects(top)
            || lineSegment.intersects(bottom)
            || lineSegment.intersects(left)
            || lineSegment.intersects(right)
    }
}
