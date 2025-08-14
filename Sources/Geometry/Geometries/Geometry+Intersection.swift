import CoreGraphics
import Numerics

// TODO: This file needs a big ol' cleanup

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
    func intersects(_ lineSegment: LineSegment, absoluteTolerance: CGFloat = 1e-5) -> Bool {
        let p = start
        let q = lineSegment.start
        let r = end - start
        let s = lineSegment.end - lineSegment.start

        let rxs = r.cross(s)
        let qpxr = (q - p).cross(r)

        // Check if lines are parallel
        if rxs.isApproximatelyEqual(to: 0, absoluteTolerance: absoluteTolerance) {
            // Check if they are collinear
            if qpxr.isApproximatelyEqual(to: 0, absoluteTolerance: absoluteTolerance) {
                // Check for overlap
                let t0 = (q - p).dot(r) / r.dot(r)
                let t1 = t0 + s.dot(r) / r.dot(r)
                return (t0 >= 0 && t0 <= 1) || (t1 >= 0 && t1 <= 1) || (t0 < 0 && t1 > 1) || (t1 < 0 && t0 > 1)
            }
            return false // Parallel but not collinear
        }

        let t = (q - p).cross(s) / rxs
        let u = (q - p).cross(r) / rxs

        return t >= -absoluteTolerance && t <= 1 + absoluteTolerance && u >= -absoluteTolerance && u <= 1 + absoluteTolerance
    }

    /// Perform intersection as if self and target are convert to infinite lines
    func infiniteIntesection(_ target: LineSegment, absoluteTolerance: CGFloat = 1e-5) -> CGPoint? {
        Line(self).intersection(with: Line(target), absoluteTolerance: absoluteTolerance)
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
        let x1 = start.x, y1 = start.y
        let x2 = end.x, y2 = end.y
        let x3 = other.start.x, y3 = other.start.y
        let x4 = other.end.x, y4 = other.end.y
        
        let denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
        
        if denom.isApproximatelyEqual(to: 0, absoluteTolerance: absoluteTolerance) {
            return nil
        }
        
        let t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denom
        let u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / denom
        
        if t >= 0 && t <= 1 && u >= 0 && u <= 1 {
            let x = x1 + t * (x2 - x1)
            let y = y1 + t * (y2 - y1)
            return CGPoint(x: x, y: y)
        }
        
        return nil
    }
    
    /// Check if this segment overlaps with another segment (collinear and share points)
    func overlaps(_ other: LineSegment, tolerance: CGFloat = 1e-1) -> Bool {
        let thisStartOnOther = other.contains(start, within: tolerance)
        let thisEndOnOther = other.contains(end, within: tolerance)
        
        let otherStartOnThis = self.contains(other.start, within: tolerance)
        let otherEndOnThis = self.contains(other.end, within: tolerance)
        
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
    // TODO: Use isApproximatelyEqual.
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

// MARK: Misc

// TODO: Move to extension on CGPoint perhaps?
public func intersectionOfLines(_ p1: CGPoint, _ d1: CGPoint, _ p2: CGPoint, _ d2: CGPoint, absoluteTolerance: CGFloat = 1e-6) -> CGPoint? {
    let cross = d1.x * d2.y - d1.y * d2.x
    guard !cross.isApproximatelyEqual(to: 0, absoluteTolerance: absoluteTolerance) else { return nil }

    let diff = p2 - p1
    let t = (diff.x * d2.y - diff.y * d2.x) / cross
    return p1 + d1 * t
}
