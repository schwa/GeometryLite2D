import CoreGraphics

// TODO: This file needs a big ol' cleanup

// MARK: Line

public extension Line {
    func intersection(with other: Line, epsilon: CGFloat = 1e-6) -> CGPoint? {
        let dx = other.point.x - point.x
        let dy = other.point.y - point.y

        let det = direction.dx * other.direction.dy - direction.dy * other.direction.dx
        if abs(det) < epsilon {
            return nil // lines are parallel
        }

        let t = (dx * other.direction.dy - dy * other.direction.dx) / det
        return CGPoint(x: point.x + t * direction.dx, y: point.y + t * direction.dy)
    }
}

// MARK: LineSegment

public extension LineSegment {
    func intersects(_ lineSegment: LineSegment, epsilon: CGFloat = 1e-5) -> Bool {
        let p = start
        let q = lineSegment.start
        let r = end - start
        let s = lineSegment.end - lineSegment.start

        let rxs = r.cross(s)
        let qpxr = (q - p).cross(r)

        // Check if lines are parallel
        if abs(rxs) < epsilon {
            // Check if they are collinear
            if abs(qpxr) < epsilon {
                // Check for overlap
                let t0 = (q - p).dot(r) / r.dot(r)
                let t1 = t0 + s.dot(r) / r.dot(r)
                return (t0 >= 0 && t0 <= 1) || (t1 >= 0 && t1 <= 1) || (t0 < 0 && t1 > 1) || (t1 < 0 && t0 > 1)
            }
            return false // Parallel but not collinear
        }

        let t = (q - p).cross(s) / rxs
        let u = (q - p).cross(r) / rxs

        return t >= -epsilon && t <= 1 + epsilon && u >= -epsilon && u <= 1 + epsilon
    }

    /// Perform intersection as if self and target are convert to infinite lines
    func infiniteIntesection(_ target: LineSegment, epsilon: CGFloat = 1e-5) -> CGPoint? {
        Line(self).intersection(with: Line(target), epsilon: epsilon)
    }

    func intersection(_ ray: Ray, epsilon: CGFloat = 1e-5) -> CGPoint? {
        let p = ray.origin
        let r = ray.direction

        let q = start
        let s = end - start

        let rCrossS = r.dx * s.y - r.dy * s.x
        if abs(rCrossS) < epsilon {
            // Lines are parallel or colinear
            return nil
        }

        let qp = CGVector(dx: q.x - p.x, dy: q.y - p.y)
        let t = (qp.dx * s.y - qp.dy * s.x) / rCrossS
        let u = (qp.dx * r.dy - qp.dy * r.dx) / rCrossS

        // Ray: t >= 0, Segment: u in [0,1]
        if t >= -epsilon, u >= -epsilon, u <= 1 + epsilon {
            return CGPoint(x: p.x + t * r.dx, y: p.y + t * r.dy)
        }
        return nil
    }

    func intersects(with rect: CGRect) -> Bool {
        rect.intersects(with: self)
    }
}

// MARK: -

public extension Ray {
    func intersection(with other: Ray, epsilon: CGFloat = 1e-6) -> CGPoint? {
        let dx = other.origin.x - origin.x
        let dy = other.origin.y - origin.y

        let det = direction.dx * other.direction.dy - direction.dy * other.direction.dx
        if abs(det) < epsilon {
            return nil // Parallel rays
        }

        // Solve for t in self.point(at: t)
        let t = (dx * other.direction.dy - dy * other.direction.dx) / det
        if t < -epsilon {
            return nil // Intersection is behind self
        }

        // Solve for u in other.point(at: u)
        let u = (dx * direction.dy - dy * direction.dx) / det
        if u < -epsilon {
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
        if abs(rCrossS) < .ulpOfOne {
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
    // TODO: Add epsilon
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
public func intersectionOfLines(_ p1: CGPoint, _ d1: CGPoint, _ p2: CGPoint, _ d2: CGPoint) -> CGPoint? {
    let cross = d1.x * d2.y - d1.y * d2.x
    guard abs(cross) >= 1e-6 else { return nil }

    let diff = p2 - p1
    let t = (diff.x * d2.y - diff.y * d2.x) / cross
    return p1 + d1 * t
}
