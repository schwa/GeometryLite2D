import CoreGraphics
import Geometry
import SwiftUI

// MARK: - Joint Edge Lines

/// The four edge lines at a joint between two segments
internal struct JointEdgeLines {
    let ourLeft: Line
    let ourRight: Line
    let otherLeft: Line
    let otherRight: Line

    /// Create the four edge lines at a joint point
    init(
        at point: CGPoint,
        ourDirection: CGVector,
        ourNormal: CGVector,
        otherDirection: CGVector,
        halfWidth: CGFloat
    ) {
        let otherNormal = otherDirection.perpendicular * halfWidth
        ourLeft = Line(point: point + ourNormal, direction: ourDirection)
        ourRight = Line(point: point - ourNormal, direction: ourDirection)
        otherLeft = Line(point: point + otherNormal, direction: otherDirection)
        otherRight = Line(point: point - otherNormal, direction: otherDirection)
    }
}

// MARK: - Joint Endpoint Adjustment

/// Adjust left/right endpoint positions at a joint
/// - Returns: Adjusted (left, right) positions accounting for miter/bevel and knee-pit bounds
private func adjustedEndpoints(
    at point: CGPoint,
    direction: CGVector,
    normal: CGVector,
    joint: JointEnd,
    segmentLength: CGFloat,
    width: CGFloat,
    halfWidth: CGFloat,
    leftIsOuter: Bool
) -> (left: CGPoint, right: CGPoint) {
    var left = point + normal
    var right = point - normal

    let edges = JointEdgeLines(at: point, ourDirection: direction, ourNormal: normal, otherDirection: joint.otherDirection, halfWidth: halfWidth)
    let maxDist = min(segmentLength, joint.otherLength)

    let useMiter: Bool
    if case .miter(let limit) = joint.joinStyle {
        let outerLine = leftIsOuter ? edges.ourLeft : edges.ourRight
        let otherOuterLine = leftIsOuter ? edges.otherLeft : edges.otherRight
        if let p = outerLine.intersection(with: otherOuterLine) {
            useMiter = point.distance(to: p) / width <= limit
        } else {
            useMiter = false
        }
    } else {
        useMiter = false
    }

    if leftIsOuter {
        if useMiter, let p = edges.ourLeft.intersection(with: edges.otherLeft) {
            left = p
        }
        if let p = edges.ourRight.intersection(with: edges.otherRight), point.distance(to: p) < maxDist {
            right = p
        }
    } else {
        if useMiter, let p = edges.ourRight.intersection(with: edges.otherRight) {
            right = p
        }
        if let p = edges.ourLeft.intersection(with: edges.otherLeft), point.distance(to: p) < maxDist {
            left = p
        }
    }

    return (left, right)
}

// MARK: - Joint End

/// Information about how a segment connects at one of its ends
internal struct JointEnd {
    /// Direction of the other segment (pointing toward the joint for start, away for end)
    var otherDirection: CGVector
    /// Length of the other segment (for bounds checking)
    var otherLength: CGFloat
    /// The join style to use
    var joinStyle: JoinStyle

    init(otherDirection: CGVector, otherLength: CGFloat, joinStyle: JoinStyle = .miter) {
        self.otherDirection = otherDirection
        self.otherLength = otherLength
        self.joinStyle = joinStyle
    }
}

// MARK: - Segment Thickening

/// Convert a line segment into enclosed atoms (body + optional end caps)
internal func thickenedSegment(
    _ segment: LineSegment,
    width: CGFloat,
    startCap: CapStyle = .butt,
    endCap: CapStyle = .butt,
    startJoint: JointEnd? = nil,
    endJoint: JointEnd? = nil
) -> [Atom] {
    let halfWidth = width / 2
    let normal = segment.normal * halfWidth
    let dir = segment.direction
    let start = segment.start
    let end = segment.end

    var startLeft = start + normal
    var startRight = start - normal
    var endLeft = end + normal
    var endRight = end - normal

    // Adjust for start joint
    if let joint = startJoint {
        let cross = joint.otherDirection.cross(dir)
        let adjusted = adjustedEndpoints(
            at: start, direction: dir, normal: normal, joint: joint,
            segmentLength: segment.length, width: width, halfWidth: halfWidth,
            leftIsOuter: cross < 0
        )
        startLeft = adjusted.left
        startRight = adjusted.right
    }

    // Adjust for end joint
    if let joint = endJoint {
        let cross = dir.cross(joint.otherDirection)
        let adjusted = adjustedEndpoints(
            at: end, direction: dir, normal: normal, joint: joint,
            segmentLength: segment.length, width: width, halfWidth: halfWidth,
            leftIsOuter: cross < 0
        )
        endLeft = adjusted.left
        endRight = adjusted.right
    }

    var atoms: [Atom] = []

    // Determine body polygon vertices based on cap styles
    let effectiveStartCap = startJoint == nil ? startCap : .butt
    let effectiveEndCap = endJoint == nil ? endCap : .butt

    var bodyVertices: [CGPoint] = []

    // Start edge
    bodyVertices.append(startLeft)
    if effectiveStartCap == .square {
        let extend = dir * halfWidth
        bodyVertices.append((start + normal) - extend)
        bodyVertices.append((start - normal) - extend)
    }
    bodyVertices.append(startRight)

    // End edge
    bodyVertices.append(endRight)
    if effectiveEndCap == .square {
        let extend = dir * halfWidth
        bodyVertices.append((end - normal) + extend)
        bodyVertices.append((end + normal) + extend)
    }
    bodyVertices.append(endLeft)

    atoms.append(.polygon(vertices: bodyVertices))

    // Round start cap (semicircle)
    if effectiveStartCap == .round {
        atoms.append(.pieslice(
            apex: startLeft,
            arcCenter: start,
            p0: startLeft,
            p2: startRight,
            clockwise: false
        ))
    }

    // Round end cap (semicircle)
    if effectiveEndCap == .round {
        atoms.append(.pieslice(
            apex: endRight,
            arcCenter: end,
            p0: endRight,
            p2: endLeft,
            clockwise: false
        ))
    }

    return atoms
}

// MARK: - Joint Corners

/// The outer and inner corner points at a joint between two segments
internal struct JointCorners {
    let outer1: CGPoint
    let outer2: CGPoint
    let inner1: CGPoint
    let inner2: CGPoint
    let cross: CGFloat

    init(center: CGPoint, direction1: CGVector, direction2: CGVector, halfWidth: CGFloat) {
        let normal1 = direction1.perpendicular * halfWidth
        let normal2 = direction2.perpendicular * halfWidth
        cross = direction1.cross(direction2)

        if cross > 0 {
            outer1 = center - normal1
            outer2 = center - normal2
            inner1 = center + normal1
            inner2 = center + normal2
        } else {
            outer1 = center + normal1
            outer2 = center + normal2
            inner1 = center - normal1
            inner2 = center - normal2
        }
    }
}

// MARK: - Miter Limit Check

/// Check if miter limit is exceeded at a joint
internal func miterLimitExceeded(
    center: CGPoint,
    direction1: CGVector,
    direction2: CGVector,
    width: CGFloat,
    limit: CGFloat
) -> Bool {
    let corners = JointCorners(center: center, direction1: direction1, direction2: direction2, halfWidth: width / 2)

    let outerLine1 = Line(point: corners.outer1, direction: direction1)
    let outerLine2 = Line(point: corners.outer2, direction: direction2)

    if let miterPoint = outerLine1.intersection(with: outerLine2) {
        let miterLength = center.distance(to: miterPoint)
        return miterLength / width > limit
    }
    return true
}

// MARK: - Knee Pit (Inner Clip Point)

/// Compute the knee-pit point (where inner edges meet) with bounds checking
internal func kneePit(
    center: CGPoint,
    direction1: CGVector,
    direction2: CGVector,
    length1: CGFloat,
    length2: CGFloat,
    width: CGFloat
) -> CGPoint {
    let corners = JointCorners(center: center, direction1: direction1, direction2: direction2, halfWidth: width / 2)

    let innerLine1 = Line(point: corners.inner1, direction: direction1)
    let innerLine2 = Line(point: corners.inner2, direction: direction2)

    if let p = innerLine1.intersection(with: innerLine2) {
        let toP = CGVector(dx: p.x - center.x, dy: p.y - center.y)

        let proj1 = toP.dot(direction1)
        let withinSeg1 = proj1 <= 0 && abs(proj1) <= length1

        let proj2 = toP.dot(direction2)
        let withinSeg2 = proj2 >= 0 && proj2 <= length2

        if withinSeg1, withinSeg2 {
            return p
        }
    }
    return center
}

// MARK: - Knee Caps

/// Generate a knee cap atom for a joint (bevel or round)
internal func kneeCap(
    center: CGPoint,
    direction1: CGVector,
    direction2: CGVector,
    length1: CGFloat,
    length2: CGFloat,
    width: CGFloat,
    style: JoinStyle
) -> Atom? {
    let corners = JointCorners(center: center, direction1: direction1, direction2: direction2, halfWidth: width / 2)
    let clipPt = kneePit(center: center, direction1: direction1, direction2: direction2, length1: length1, length2: length2, width: width)

    switch style {
    case .bevel:
        return .wedge(apex: clipPt, p0: corners.outer1, p2: corners.outer2)

    case .round:
        return .pieslice(apex: clipPt, arcCenter: center, p0: corners.outer1, p2: corners.outer2, clockwise: corners.cross < 0)

    case .miter:
        return nil
    }
}
