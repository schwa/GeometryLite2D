import CoreGraphics

// MARK: - Utility Functions

private func approxZero(_ value: CGFloat, epsilon: CGFloat) -> Bool { 
    abs(value) <= epsilon 
}

private func clamp<T: Comparable>(_ value: T, _ lower: T, _ upper: T) -> T { 
    min(max(value, lower), upper) 
}

// MARK: - Intersection Types

public enum Intersection<ParamA: Comparable, ParamB: Comparable> {
    
    /// Half-open numeric interval [lower, upper] (upper < lower => empty)
    public struct Interval<T: Comparable> {
        public var lower: T
        public var upper: T
        
        public init(lower: T, upper: T) {
            self.lower = lower
            self.upper = upper
        }
        
        public var isEmpty: Bool {
            upper < lower
        }
    }
    
    /// Overlap of two param domains (e.g., segment t in [0,1])
    public struct ParamOverlap {
        public var intervalA: Interval<ParamA>
        public var intervalB: Interval<ParamB>
        
        public init(intervalA: Interval<ParamA>, intervalB: Interval<ParamB>) {
            self.intervalA = intervalA
            self.intervalB = intervalB
        }
    }
    
    public enum FeatureID: Equatable {
        case vertex(Int)
        case edge(Int)
    }
    
    /// Single contact/hit point.
    public struct Hit {
        public enum Kind {
            case crossing
            case enter
            case exit
            case tangent
        }
        
        public struct Info<Param> {
            public var parameter: Param?
            public var normal: CGPoint?
            public var feature: FeatureID?
            
            public init(parameter: Param? = nil, normal: CGPoint? = nil, feature: FeatureID? = nil) {
                self.parameter = parameter
                self.normal = normal
                self.feature = feature
            }
        }
        
        public var point: CGPoint
        public var kind: Kind
        public var infoA: Info<ParamA>
        public var infoB: Info<ParamB>
        
        public init(point: CGPoint, kind: Kind = .crossing, infoA: Info<ParamA> = Info(), infoB: Info<ParamB> = Info()) {
            self.point = point
            self.kind = kind
            self.infoA = infoA
            self.infoB = infoB
        }
        
        // Convenience init for backwards compatibility
        public init(point: CGPoint, kind: Kind = .crossing, parameterA: ParamA? = nil, parameterB: ParamB? = nil, normalA: CGPoint? = nil, normalB: CGPoint? = nil, featureA: FeatureID? = nil, featureB: FeatureID? = nil) {
            self.point = point
            self.kind = kind
            self.infoA = Info(parameter: parameterA, normal: normalA, feature: featureA)
            self.infoB = Info(parameter: parameterB, normal: normalB, feature: featureB)
        }
    }
    
    /// A span is a 1D overlap along two features (usually edges).
    public struct Span {
        public var featureA: FeatureID
        public var rangeA: Interval<ParamA>
        public var featureB: FeatureID
        public var rangeB: Interval<ParamB>
    }
    
    public enum Relation {
        case disjoint
        case properIntersect
        case tangentContact
        case coincident
        case containment
    }
    
    case none(closest: (a: CGPoint, b: CGPoint)? = nil, separation: CGFloat? = nil, relation: Relation = .disjoint)
    case finite(hits: [Hit], spans: [Span] = [], relation: Relation)
    case infinite(overlap: ParamOverlap, relation: Relation = .coincident)
}

// MARK: - CustomStringConvertible

extension Intersection: CustomStringConvertible {
    public var description: String {
        switch self {
        case .none(_, let separation, let relation):
            var parts = ["none(\(relation))"]
            if let sep = separation { parts.append("sep: \(String(format: "%.3f", sep))") }
            return parts.joined(separator: " ")
        case .finite(let hits, let spans, let relation):
            return "finite(\(relation)) \(hits.count) hits, \(spans.count) spans"
        case .infinite(_, let relation):
            return "infinite(\(relation))"
        }
    }
}

extension Intersection.Interval: CustomStringConvertible {
    public var description: String {
        isEmpty ? "empty" : "[\(lower)..\(upper)]"
    }
}

extension Intersection.ParamOverlap: CustomStringConvertible {
    public var description: String {
        "overlap(A:\(intervalA) B:\(intervalB))"
    }
}

extension Intersection.FeatureID: CustomStringConvertible {
    public var description: String {
        switch self {
        case .vertex(let i): return "vertex(\(i))"
        case .edge(let i): return "edge(\(i))"
        }
    }
}

extension Intersection.Hit: CustomStringConvertible {
    public var description: String {
        let pt = String(format: "(%.2f, %.2f)", point.x, point.y)
        return "\(kind) at \(pt)"
    }
}

extension Intersection.Hit.Info: CustomStringConvertible {
    public var description: String {
        var parts: [String] = []
        if let param = parameter { parts.append("t:\(param)") }
        if let feature = feature { parts.append("\(feature)") }
        if let normal = normal { 
            parts.append(String(format: "n:(%.2f,%.2f)", normal.x, normal.y)) 
        }
        return parts.isEmpty ? "none" : parts.joined(separator: " ")
    }
}

extension Intersection.Hit.Kind: CustomStringConvertible {
    public var description: String {
        switch self {
        case .crossing: return "crossing"
        case .enter: return "enter"
        case .exit: return "exit"
        case .tangent: return "tangent"
        }
    }
}

extension Intersection.Span: CustomStringConvertible {
    public var description: String {
        "span(\(featureA):\(rangeA) to \(featureB):\(rangeB))"
    }
}

extension Intersection.Relation: CustomStringConvertible {
    public var description: String {
        switch self {
        case .disjoint: return "disjoint"
        case .properIntersect: return "intersect"
        case .tangentContact: return "tangent"
        case .coincident: return "coincident"
        case .containment: return "contains"
        }
    }
}


// MARK: - Segment ⟂ Segment

public func intersect(_ segment1: LineSegment, _ segment2: LineSegment, epsilon: CGFloat = 1e-9) -> Intersection<CGFloat, CGFloat> {
    let start1 = segment1.start
    let direction1 = segment1.end - segment1.start  // Full vector, not unit
    let start2 = segment2.start
    let direction2 = segment2.end - segment2.start  // Full vector, not unit

    let directionsCross = direction1.cross(direction2)
    let startDifference = start2 - start1
    let startDiffCrossDir1 = startDifference.cross(direction1)

    // Parallel
    if approxZero(directionsCross, epsilon: epsilon) {
        // Collinear
        if approxZero(startDiffCrossDir1, epsilon: epsilon) {
            let dir1LengthSquared = max(direction1.dot(direction1), epsilon)
            let t0 = (start2 - start1).dot(direction1) / dir1LengthSquared
            let t1 = t0 + direction2.dot(direction1) / dir1LengthSquared
            let tMin = min(t0, t1)
            let tMax = max(t0, t1)
            let overlap = Intersection<CGFloat, CGFloat>.Interval(lower: max(0, tMin), upper: min(1, tMax))
            if overlap.isEmpty {
                return .none()
            }

            // Map back to segment2's param [0,1]
            let denominator = (t1 - t0)
            let safeDenominator = abs(denominator) < epsilon ? 1 : denominator
            let u0 = (overlap.lower - t0) / safeDenominator
            let u1 = (overlap.upper - t0) / safeDenominator
            return .infinite(overlap: .init(intervalA: overlap, intervalB: .init(lower: min(u0, u1), upper: max(u0, u1))), relation: .coincident)
        }
        return .none()
    }

    // Not parallel — solve for parameters
    let param1 = startDifference.cross(direction2) / directionsCross
    let param2 = startDifference.cross(direction1) / directionsCross

    if param1 >= -epsilon && param1 <= 1 + epsilon && param2 >= -epsilon && param2 <= 1 + epsilon {
        let intersectionPoint = start1 + direction1 * param1
        let isTangent = (abs(param1) < epsilon || abs(param1 - 1) < epsilon ||
                         abs(param2) < epsilon || abs(param2 - 1) < epsilon)
        let hit = Intersection<CGFloat, CGFloat>.Hit(point: intersectionPoint, 
                                                      kind: isTangent ? .tangent : .crossing, 
                                                      parameterA: param1, 
                                                      parameterB: param2)
        return .finite(hits: [hit], relation: isTangent ? .tangentContact : .properIntersect)
    }

    // Miss: return optional closest points & separation
    let closestPts = closestPoints(segment1, segment2)
    let separation = (closestPts.a - closestPts.b).length
    return .none(closest: closestPts, separation: separation)
}

// Closest points between two segments (for miss reporting)
private func closestPoints(_ segment1: LineSegment, _ segment2: LineSegment) -> (a: CGPoint, b: CGPoint) {
    // Based on Real-Time Collision Detection (Christer Ericson), clamped
    let start1 = segment1.start, end1 = segment1.end
    let start2 = segment2.start, end2 = segment2.end
    let direction1 = end1 - start1
    let direction2 = end2 - start2
    let startDifference = start1 - start2
    let dir1DotDir1 = direction1.dot(direction1) // always nonnegative
    let dir2DotDir2 = direction2.dot(direction2)
    let dir2DotStartDiff = direction2.dot(startDifference)

    var param1: CGFloat = 0
    var param2: CGFloat = 0

    if dir1DotDir1 <= 0 && dir2DotDir2 <= 0 { return (start1, start2) }
    if dir1DotDir1 <= 0 { // segment1 is a point
        param1 = 0
        param2 = clamp(dir2DotStartDiff / dir2DotDir2, 0, 1)
    } else if dir2DotDir2 <= 0 { // segment2 is a point
        param2 = 0
        param1 = clamp(-direction1.dot(startDifference) / dir1DotDir1, 0, 1)
    } else {
        let dir1DotDir2 = direction1.dot(direction2)
        let dir1DotStartDiff = direction1.dot(startDifference)
        let denominator = dir1DotDir1 * dir2DotDir2 - dir1DotDir2 * dir1DotDir2
        if denominator != 0 { 
            param1 = clamp((dir1DotDir2 * dir2DotStartDiff - dir1DotStartDiff * dir2DotDir2) / denominator, 0, 1) 
        } else { 
            param1 = 0 
        }
        let param2Unclamped = (dir1DotDir2 * param1 + dir2DotStartDiff) / dir2DotDir2
        param2 = clamp(param2Unclamped, 0, 1)
        // Recompute param1 if param2 was clamped
        let paramDiff = param2 - param2Unclamped
        if abs(paramDiff) > 0 {
            param1 = clamp((dir1DotDir2 * param2 - dir1DotStartDiff) / dir1DotDir1, 0, 1)
        }
    }
    return (start1 + direction1 * param1, start2 + direction2 * param2)
}

// MARK: - Segment ⟂ Circle

public func intersect(_ segment: LineSegment, _ circle: Circle, epsilon: CGFloat = 1e-9) -> Intersection<CGFloat, CGFloat> {
    let segmentStart = segment.start
    let segmentDirection = segment.end - segment.start  // Full vector, not unit
    let centerToStart = segmentStart - circle.center

    let coefficientA = segmentDirection.dot(segmentDirection)
    let coefficientB = 2 * centerToStart.dot(segmentDirection)
    let coefficientC = centerToStart.dot(centerToStart) - circle.radius * circle.radius

    // Early out: degenerate segment
    if coefficientA <= epsilon {
        let distance = centerToStart.length
        if abs(distance - circle.radius) <= epsilon {
            // Endpoint tangent
            let normal = centerToStart / centerToStart.length
            let hit = Intersection<CGFloat, CGFloat>.Hit(point: segmentStart, kind: .tangent, parameterA: 0, parameterB: 0, normalB: normal)
            return .finite(hits: [hit], relation: .tangentContact)
        }
        if distance < circle.radius {
            return .finite(hits: [], relation: .containment)
        }
        let closestOnCircle = circle.center + (centerToStart / centerToStart.length) * circle.radius
        return .none(closest: (a: segmentStart, b: closestOnCircle), separation: abs(distance - circle.radius))
    }

    let discriminant = coefficientB * coefficientB - 4 * coefficientA * coefficientC
    if discriminant < -epsilon { // no real roots
        // report closest point & separation
        let parameter = clamp(-centerToStart.dot(segmentDirection) / coefficientA, 0, 1)
        let closestPoint = segmentStart + segmentDirection * parameter
        let vectorToCenter = closestPoint - circle.center
        let delta = vectorToCenter.length - circle.radius
        let closestOnCircle = circle.center + (vectorToCenter / vectorToCenter.length) * circle.radius
        return .none(closest: (a: closestPoint, b: closestOnCircle), separation: abs(delta))
    }

    if abs(discriminant) <= epsilon {
        // Tangent (one hit)
        let parameter = -coefficientB / (2 * coefficientA)
        if parameter >= -epsilon && parameter <= 1 + epsilon {
            let point = segmentStart + segmentDirection * parameter
            let normal = (point - circle.center) / (point - circle.center).length
            let hit = Intersection<CGFloat, CGFloat>.Hit(point: point, kind: .tangent, parameterA: parameter, parameterB: 0, normalB: normal)
            return .finite(hits: [hit], relation: .tangentContact)
        }
        return .none()
    }

    // Two roots
    let sqrtDiscriminant = sqrt(max(discriminant, 0))
    var parameter1 = (-coefficientB - sqrtDiscriminant) / (2 * coefficientA)
    var parameter2 = (-coefficientB + sqrtDiscriminant) / (2 * coefficientA)
    if parameter1 > parameter2 {
        swap(&parameter1, &parameter2)
    }

    var hits: [Intersection<CGFloat, CGFloat>.Hit] = []
    if parameter1 >= -epsilon && parameter1 <= 1 + epsilon {
        let point = segmentStart + segmentDirection * parameter1
        let normal = (point - circle.center) / (point - circle.center).length
        hits.append(Intersection<CGFloat, CGFloat>.Hit(point: point, kind: .crossing, parameterA: parameter1, parameterB: 0, normalB: normal))
    }
    if parameter2 >= -epsilon && parameter2 <= 1 + epsilon {
        let point = segmentStart + segmentDirection * parameter2
        let normal = (point - circle.center) / (point - circle.center).length
        hits.append(Intersection<CGFloat, CGFloat>.Hit(point: point, kind: .crossing, parameterA: parameter2, parameterB: 0, normalB: normal))
    }
    if !hits.isEmpty {
        return .finite(hits: hits, relation: .properIntersect)
    }
    return .none()
}

// MARK: - Segment ⟂ Polygon

public func intersect(_ segment: LineSegment, _ polygon: Polygon, epsilon: CGFloat = 1e-9) -> Intersection<CGFloat, CGFloat> {
    let vertices = polygon.vertices
    guard vertices.count >= 3 else {
        return .none()
    }

    var hits: [Intersection<CGFloat, CGFloat>.Hit] = []
    var spans: [Intersection<CGFloat, CGFloat>.Span] = []

    // 1) Edge-edge tests
    for i in 0..<vertices.count {
        let vertexA = vertices[i]
        let vertexB = vertices[(i + 1) % vertices.count]
        let edge = LineSegment(start: vertexA, end: vertexB)
        switch intersect(segment, edge, epsilon: epsilon) {
        case .finite(let edgeHits, _, let relation):
            let kind: Intersection<CGFloat, CGFloat>.Hit.Kind = (relation == .tangentContact) ? .tangent : .crossing
            for hit in edgeHits {
                hits.append(Intersection<CGFloat, CGFloat>.Hit(point: hit.point,
                                                               kind: kind,
                                                               parameterA: hit.infoA.parameter, 
                                                               parameterB: hit.infoB.parameter,
                                                               featureA: .edge(-1), // segment has implicit single edge
                                                               featureB: .edge(i)))
            }
        case .infinite(let overlap, _):
            spans.append(Intersection<CGFloat, CGFloat>.Span(featureA: .edge(-1), 
                                                              rangeA: overlap.intervalA, 
                                                              featureB: .edge(i), 
                                                              rangeB: overlap.intervalB))
        case .none:
            break
        }
    }

    if !spans.isEmpty {
        return .finite(hits: hits, spans: spans, relation: .coincident)
    }
    if !hits.isEmpty {
        return .finite(hits: hits, relation: .properIntersect)
    }

    // 2) No boundary contacts — containment?
    let insideA = pointInPolygon(segment.start, vertices, epsilon: epsilon)
    let insideB = pointInPolygon(segment.end, vertices, epsilon: epsilon)
    if insideA && insideB {
        return .finite(hits: [], relation: .containment)
    }

    return .none()
}

// Point-in-polygon: winding via ray casting; on-edge => inside
private func pointInPolygon(_ point: CGPoint, _ vertices: [CGPoint], epsilon: CGFloat) -> Bool {
    // quick on-edge test
    for i in 0..<vertices.count {
        let vertexA = vertices[i]
        let vertexB = vertices[(i + 1) % vertices.count]
        let edgeVector = vertexB - vertexA
        let pointVector = point - vertexA
        if approxZero(edgeVector.cross(pointVector), epsilon: epsilon) && (point - vertexA).dot(point - vertexB) <= 0 {
            return true
        }
    }
    var inside = false
    for i in 0..<vertices.count {
        let vertexA = vertices[i]
        let vertexB = vertices[(i + 1) % vertices.count]
        let yCondition = (vertexA.y > point.y) != (vertexB.y > point.y)
        if yCondition {
            let xIntersection = vertexA.x + (vertexB.x - vertexA.x) * (point.y - vertexA.y) / ((vertexB.y - vertexA.y) + 1e-300)
            if point.x < xIntersection {
                inside.toggle()
            }
        }
    }
    return inside
}

// MARK: -

