import CoreGraphics
import Geometry
import SwiftUI

// MARK: - Junction Helpers

/// Handle 2-segment junction - just a polyline through the center
internal func twoWayJunction(
    center: CGPoint,
    endpoints: [CGPoint],
    width: CGFloat,
    joinStyle: JoinStyle,
    capStyle: CapStyle
) -> [Atom] {
    Polyline(vertices: [endpoints[0], center, endpoints[1]]).thickened(
        width: width,
        joinStyle: joinStyle,
        capStyle: capStyle
    )
}

/// Handle N-way junction (N > 2)
internal func nWayJunction(
    center: CGPoint,
    endpoints: [CGPoint],
    width: CGFloat,
    joinStyle: JoinStyle,
    capStyles: [CapStyle]
) -> [Atom] {
    // Pair segments with their original cap styles, then sort by angle
    var segmentsWithCaps: [(segment: LineSegment, capStyle: CapStyle)] = zip(endpoints, capStyles).map { endpoint, cap in
        (LineSegment(start: center, end: endpoint), cap)
    }
    segmentsWithCaps.sort { atan2($0.segment.direction.dy, $0.segment.direction.dx) < atan2($1.segment.direction.dy, $1.segment.direction.dx) }

    let segments = segmentsWithCaps.map(\.segment)
    let sortedCapStyles = segmentsWithCaps.map(\.capStyle)

    let n = segments.count
    let halfWidth = width / 2
    var atoms: [Atom] = []

    var gaps: [CGFloat] = []
    for i in 0..<n {
        let next = (i + 1) % n
        let angle1 = atan2(segments[i].direction.dy, segments[i].direction.dx)
        let angle2 = atan2(segments[next].direction.dy, segments[next].direction.dx)
        var gap = angle2 - angle1
        if gap <= 0 { gap += 2 * .pi }
        gaps.append(gap)
    }

    for i in 0..<n {
        let seg = segments[i]
        let prevIdx = (i - 1 + n) % n
        let nextIdx = (i + 1) % n

        let prevSeg = segments[prevIdx]
        let nextSeg = segments[nextIdx]

        let leftGap = gaps[prevIdx]
        let rightGap = gaps[i]

        let leftIsOuter = leftGap > .pi
        let rightIsOuter = rightGap > .pi

        let dir = seg.direction
        let normal = dir.perpendicular * halfWidth

        var startLeft = center + normal
        var startRight = center - normal

        let endLeft = seg.end + normal
        let endRight = seg.end - normal

        let prevNormal = prevSeg.direction.perpendicular * halfWidth
        let nextNormal = nextSeg.direction.perpendicular * halfWidth

        let ourLeftLine = Line(point: center + normal, direction: dir)
        let ourRightLine = Line(point: center - normal, direction: dir)
        let nextRightLine = Line(point: center - nextNormal, direction: nextSeg.direction)
        let prevLeftLine = Line(point: center + prevNormal, direction: prevSeg.direction)

        let miterLimit: CGFloat
        if case .miter(let limit) = joinStyle { miterLimit = limit } else { miterLimit = 0 }
        let isMiter = miterLimit > 0

        var rightMiterOK = true
        var leftMiterOK = true
        if isMiter, rightIsOuter {
            if let p = ourLeftLine.intersection(with: nextRightLine) {
                rightMiterOK = center.distance(to: p) / width <= miterLimit
            }
        }
        if isMiter, leftIsOuter {
            if let p = ourRightLine.intersection(with: prevLeftLine) {
                leftMiterOK = center.distance(to: p) / width <= miterLimit
            }
        }

        if !rightIsOuter || (isMiter && rightMiterOK) {
            if let p = ourLeftLine.intersection(with: nextRightLine) {
                let dist = center.distance(to: p)
                let maxDist = min(seg.length, nextSeg.length)
                if dist < maxDist {
                    startLeft = p
                }
            }
        }

        if !leftIsOuter || (isMiter && leftMiterOK) {
            if let p = ourRightLine.intersection(with: prevLeftLine) {
                let dist = center.distance(to: p)
                let maxDist = min(seg.length, prevSeg.length)
                if dist < maxDist {
                    startRight = p
                }
            }
        }

        // Build body polygon based on cap style for this segment
        let segCapStyle = sortedCapStyles[i]
        var bodyVertices: [CGPoint] = [startLeft, endLeft]

        switch segCapStyle {
        case .butt:
            bodyVertices.append(endRight)

        case .square:
            let extend = dir * halfWidth
            bodyVertices.append(endLeft + extend)
            bodyVertices.append(endRight + extend)
            bodyVertices.append(endRight)

        case .round:
            bodyVertices.append(endRight)
        }

        bodyVertices.append(startRight)
        bodyVertices.append(center)

        atoms.append(.polygon(vertices: bodyVertices))

        // Add round cap pieslice if needed
        if segCapStyle == .round {
            atoms.append(.pieslice(
                apex: endLeft,
                arcCenter: seg.end,
                p0: endLeft,
                p2: endRight,
                clockwise: true
            ))
        }
    }

    // Generate knee caps for outer gaps
    for i in 0..<n {
        let gap = gaps[i]
        if gap > .pi {
            let seg1 = segments[i]
            let seg2 = segments[(i + 1) % n]

            let needsBevelCap: Bool
            switch joinStyle {
            case .bevel:
                needsBevelCap = true

            case .round:
                needsBevelCap = false

            case .miter(let limit):
                needsBevelCap = miterLimitExceeded(
                    center: center,
                    direction1: -seg1.direction,
                    direction2: seg2.direction,
                    width: width,
                    limit: limit
                )
            }

            let normal1 = seg1.direction.perpendicular * halfWidth
            let normal2 = seg2.direction.perpendicular * halfWidth
            let outer1 = center + normal1
            let outer2 = center - normal2

            if needsBevelCap {
                atoms.append(.wedge(apex: center, p0: outer1, p2: outer2))
            } else if case .round = joinStyle {
                let cross = seg1.direction.cross(seg2.direction)
                atoms.append(.pieslice(apex: center, arcCenter: center, p0: outer1, p2: outer2, clockwise: cross > 0))
            }
        }
    }

    return atoms
}
