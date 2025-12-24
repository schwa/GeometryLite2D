import CoreGraphics
import Geometry
import SwiftUI

/// Process a polyline and return thickened atoms
/// - Parameters:
///   - points: The points defining the polyline
///   - width: Stroke width
///   - joinStyle: Join style at corners
///   - capStyle: Cap style for endpoints (ignored if closed)
///   - closed: If true, adds implicit segment from last to first point
/// - Returns: Array of atoms (segments and knee caps)
public func thickenPolyline(
    points: [CGPoint],
    width: CGFloat,
    joinStyle: JoinStyle = .miter,
    capStyle: CapStyle = .butt,
    closed: Bool = false
) -> [Atom] {
    guard points.count >= 2 else {
        return []
    }

    // For closed paths, need at least 3 points to form a polygon
    if closed, points.count < 3 {
        return thickenPolyline(points: points, width: width, joinStyle: joinStyle, capStyle: capStyle, closed: false)
    }

    var segments = zip(points, points.dropFirst()).map { LineSegment(start: $0, end: $1) }

    // Add closing segment if closed
    if closed, let first = points.first, let last = points.last, first != last {
        segments.append(LineSegment(start: last, end: first))
    }

    var atoms: [Atom] = []
    let n = segments.count

    for (i, segment) in segments.enumerated() {
        var startJoint: JointEnd?
        var endJoint: JointEnd?

        let hasPrev = closed || i > 0
        let hasNext = closed || i < n - 1

        if hasPrev {
            let prevIdx = (i - 1 + n) % n
            let prevSeg = segments[prevIdx]
            startJoint = JointEnd(otherDirection: prevSeg.direction, otherLength: prevSeg.length, joinStyle: joinStyle)
        }
        if hasNext {
            let nextIdx = (i + 1) % n
            let nextSeg = segments[nextIdx]
            endJoint = JointEnd(otherDirection: nextSeg.direction, otherLength: nextSeg.length, joinStyle: joinStyle)
        }

        let segmentAtoms = thickenedSegment(
            segment,
            width: width,
            startCap: (!closed && startJoint == nil) ? capStyle : .butt,
            endCap: (!closed && endJoint == nil) ? capStyle : .butt,
            startJoint: startJoint,
            endJoint: endJoint
        )
        atoms.append(contentsOf: segmentAtoms)
    }

    // Generate knee caps at joints
    let jointCount = closed ? n : n - 1
    for i in 0..<jointCount {
        let seg1 = segments[i]
        let seg2 = segments[(i + 1) % n]

        // Determine effective cap style for this joint
        let kneeCapStyle: JoinStyle?
        switch joinStyle {
        case .bevel:
            kneeCapStyle = .bevel

        case .round:
            kneeCapStyle = .round

        case .miter(let limit):
            // Miter exceeded → fall back to bevel
            if miterLimitExceeded(center: seg1.end, direction1: seg1.direction, direction2: seg2.direction, width: width, limit: limit) {
                kneeCapStyle = .bevel
            } else {
                kneeCapStyle = nil
            }
        }

        if let kneeCapStyle, let cap = kneeCap(
            center: seg1.end,
            direction1: seg1.direction,
            direction2: seg2.direction,
            length1: seg1.length,
            length2: seg2.length,
            width: width,
            style: kneeCapStyle
        ) {
            atoms.append(cap)
        }
    }

    return atoms
}
