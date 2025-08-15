import CoreGraphics

// MARK: - CGPoint helpers

private func dot(_ a: CGPoint, _ b: CGPoint) -> CGFloat { a.x * b.x + a.y * b.y }
private func cross(_ a: CGPoint, _ b: CGPoint) -> CGFloat { a.x * b.y - a.y * b.x }
private func length2(_ v: CGPoint) -> CGFloat { dot(v, v) }
private func length(_ v: CGPoint) -> CGFloat { sqrt(length2(v)) }
private func normalize(_ v: CGPoint) -> CGPoint { let l = length(v); return l > 0 ? v / l : .zero }
private func approxZero(_ x: CGFloat, eps: CGFloat) -> Bool { abs(x) <= eps }
private func clamp<T: Comparable>(_ v: T, _ lo: T, _ hi: T) -> T { min(max(v, lo), hi) }

// MARK: - Generic intersection model (CGPoint-based)

/// Half-open numeric interval [lower, upper] (upper < lower => empty)
public struct Interval<T: Comparable> {
    public var lower: T
    public var upper: T
    public init(lower: T, upper: T) { self.lower = lower; self.upper = upper }
    public var isEmpty: Bool { upper < lower }
}

/// Overlap of two param domains (e.g., segment t in [0,1])
public struct ParamOverlap<PA: Comparable, PB: Comparable> {
    public var a: Interval<PA>
    public var b: Interval<PB>
    public init(a: Interval<PA>, b: Interval<PB>) { self.a = a; self.b = b }
}

public enum HitKind { case crossing, enter, exit, tangent }

public enum FeatureID: Equatable { case vertex(Int), edge(Int) }

/// Single contact/hit point.
public struct Hit<PA, PB> {
    public var point: CGPoint
    public var kind: HitKind
    public var tA: PA?
    public var tB: PB?
    public var normalA: CGPoint?
    public var normalB: CGPoint?
    public var featureA: FeatureID?
    public var featureB: FeatureID?
    public init(point: CGPoint, kind: HitKind = .crossing,
                tA: PA? = nil, tB: PB? = nil,
                normalA: CGPoint? = nil, normalB: CGPoint? = nil,
                featureA: FeatureID? = nil, featureB: FeatureID? = nil) {
        self.point = point; self.kind = kind; self.tA = tA; self.tB = tB
        self.normalA = normalA; self.normalB = normalB
        self.featureA = featureA; self.featureB = featureB
    }
}

/// A span is a 1D overlap along two features (usually edges).
public struct Span<PA: Comparable, PB: Comparable> {
    public var featureA: FeatureID
    public var rangeA: Interval<PA>
    public var featureB: FeatureID
    public var rangeB: Interval<PB>
}

public enum Relation { case disjoint, properIntersect, tangentContact, coincident, containment }

/// One return type for all pairs (Scalar fixed to CGFloat for CGPoint)
public enum Intersection<PA: Comparable, PB: Comparable> {
    case none(closest: (a: CGPoint, b: CGPoint)? = nil,
              separation: CGFloat? = nil,
              relation: Relation = .disjoint)

    case finite(hits: [Hit<PA, PB>], spans: [Span<PA, PB>] = [], relation: Relation)

    case infinite(overlap: ParamOverlap<PA, PB>, relation: Relation = .coincident)
}

// MARK: - Minimal shape accessors expected by these ops

// You said Segment/Circle/Polygon already exist. We only add tiny helpers.
public protocol _SegmentLike { var start: CGPoint { get }; var end: CGPoint { get } }
extension _SegmentLike {
    @inline(__always) var direction: CGPoint { end - start }
}

public protocol _CircleLike { var center: CGPoint { get }; var radius: CGFloat { get } }
public protocol _PolygonLike { var vertices: [CGPoint] { get } }

// Adapt your concrete types here by conforming via empty extensions:
extension LineSegment: _SegmentLike {}
extension Circle: _CircleLike {}
extension Polygon: _PolygonLike {}

// MARK: - Segment ⟂ Segment

public func intersect(_ s1: some _SegmentLike,
                      _ s2: some _SegmentLike,
                      epsilon: CGFloat = 1e-9)
-> Intersection<CGFloat, CGFloat> {
    let p = s1.start
    let r = s1.direction
    let q = s2.start
    let s = s2.direction

    let rxs = cross(r, s)
    let q_p = q - p
    let qpxr = cross(q_p, r)

    // Parallel
    if approxZero(rxs, eps: epsilon) {
        // Collinear
        if approxZero(qpxr, eps: epsilon) {
            let rr = max(length2(r), epsilon)
            let t0 = dot(q - p, r) / rr
            let t1 = t0 + dot(s, r) / rr
            let tmin = min(t0, t1)
            let tmax = max(t0, t1)
            let overlap = Interval(lower: max(0, tmin), upper: min(1, tmax))
            if overlap.isEmpty { return .none() }

            // Map back to s2's param [0,1]
            let denom = (t1 - t0)
            let safe = abs(denom) < epsilon ? 1 : denom
            let u0 = (overlap.lower - t0) / safe
            let u1 = (overlap.upper - t0) / safe
            return .infinite(overlap: .init(a: overlap,
                                            b: .init(lower: min(u0, u1), upper: max(u0, u1))),
                             relation: .coincident)
        }
        return .none()
    }

    // Not parallel — solve for t,u
    let t = cross(q_p, s) / rxs
    let u = cross(q_p, r) / rxs

    if t >= -epsilon && t <= 1 + epsilon && u >= -epsilon && u <= 1 + epsilon {
        let pt = p + r * t
        let tangent = (abs(t) < epsilon || abs(t - 1) < epsilon ||
                        abs(u) < epsilon || abs(u - 1) < epsilon)
        let hit = Hit<CGFloat, CGFloat>(point: pt, kind: tangent ? .tangent : .crossing, tA: t, tB: u)
        return .finite(hits: [hit], relation: tangent ? .tangentContact : .properIntersect)
    }

    // Miss: return optional closest points & separation
    let cp = _closestPoints(s1, s2)
    let sep = length(cp.a - cp.b)
    return .none(closest: cp, separation: sep)
}

// Closest points between two segments (for miss reporting)
private func _closestPoints(_ s1: _SegmentLike, _ s2: _SegmentLike) -> (a: CGPoint, b: CGPoint) {
    // Based on Real-Time Collision Detection (Christer Ericson), clamped
    let p1 = s1.start, q1 = s1.end
    let p2 = s2.start, q2 = s2.end
    let d1 = q1 - p1
    let d2 = q2 - p2
    let r = p1 - p2
    let a = dot(d1, d1) // always nonnegative
    let e = dot(d2, d2)
    let f = dot(d2, r)

    var s: CGFloat = 0
    var t: CGFloat = 0

    if a <= 0 && e <= 0 { return (p1, p2) }
    if a <= 0 { // s1 is a point
        s = 0; t = clamp(f / e, 0, 1)
    } else if e <= 0 { // s2 is a point
        t = 0; s = clamp(-dot(d1, r) / a, 0, 1)
    } else {
        let b = dot(d1, d2)
        let c = dot(d1, r)
        let denom = a * e - b * b
        if denom != 0 { s = clamp((b * f - c * e) / denom, 0, 1) } else { s = 0 }
        let tUnclamped = (b * s + f) / e
        t = clamp(tUnclamped, 0, 1)
        // Recompute s if t was clamped
        let tDiff = t - tUnclamped
        if abs(tDiff) > 0 { s = clamp((b * t - c) / a, 0, 1) }
    }

    return (p1 + d1 * s, p2 + d2 * t)
}

// MARK: - Segment ⟂ Circle

public func intersect(_ seg: some _SegmentLike,
                      _ cir: some _CircleLike,
                      epsilon: CGFloat = 1e-9)
-> Intersection<CGFloat, CGFloat> {
    let p = seg.start
    let d = seg.direction
    let m = p - cir.center

    let A = dot(d, d)
    let B = 2 * dot(m, d)
    let C = dot(m, m) - cir.radius * cir.radius

    // Early out: degenerate segment
    if A <= epsilon {
        let dist = length(m)
        if abs(dist - cir.radius) <= epsilon {
            // Endpoint tangent
            let n = normalize(m)
            let hit = Hit<CGFloat, CGFloat>(point: p, kind: .tangent, tA: 0, tB: 0, normalB: n)
            return .finite(hits: [hit], relation: .tangentContact)
        }
        if dist < cir.radius {
            return .finite(hits: [], relation: .containment)
        }
        return .none(closest: (a: p, b: cir.center + normalize(m) * cir.radius), separation: abs(dist - cir.radius))
    }

    let disc = B * B - 4 * A * C
    if disc < -epsilon { // no real roots
        // report closest point & separation
        let t = clamp(-dot(m, d) / A, 0, 1)
        let cp = p + d * t
        let delta = length(cp - cir.center) - cir.radius
        return .none(closest: (a: cp, b: cir.center + normalize(cp - cir.center) * cir.radius), separation: abs(delta))
    }

    if abs(disc) <= epsilon {
        // Tangent (one hit)
        let t = -B / (2 * A)
        if t >= -epsilon && t <= 1 + epsilon {
            let pt = p + d * t
            let n = normalize(pt - cir.center)
            let hit = Hit<CGFloat, CGFloat>(point: pt, kind: .tangent, tA: t, tB: 0, normalB: n)
            return .finite(hits: [hit], relation: .tangentContact)
        }
        return .none()
    }

    // Two roots
    let sqrtDisc = sqrt(max(disc, 0))
    var t0 = (-B - sqrtDisc) / (2 * A)
    var t1 = (-B + sqrtDisc) / (2 * A)
    if t0 > t1 { swap(&t0, &t1) }

    var hits: [Hit<CGFloat, CGFloat>] = []
    if t0 >= -epsilon && t0 <= 1 + epsilon {
        let pt = p + d * t0
        let n = normalize(pt - cir.center)
        hits.append(Hit(point: pt, kind: .crossing, tA: t0, tB: 0, normalB: n))
    }
    if t1 >= -epsilon && t1 <= 1 + epsilon {
        let pt = p + d * t1
        let n = normalize(pt - cir.center)
        hits.append(Hit(point: pt, kind: .crossing, tA: t1, tB: 0, normalB: n))
    }

    if !hits.isEmpty { return .finite(hits: hits, relation: .properIntersect) }
    return .none()
}

// MARK: - Segment ⟂ Polygon

public func intersect(_ seg: some _SegmentLike,
                      _ poly: some _PolygonLike,
                      epsilon: CGFloat = 1e-9)
-> Intersection<CGFloat, CGFloat> {
    let V = poly.vertices
    guard V.count >= 3 else { return .none() }

    var hits: [Hit<CGFloat, CGFloat>] = []
    var spans: [Span<CGFloat, CGFloat>] = []

    // 1) Edge-edge tests
    for i in 0..<V.count {
        let a = V[i]
        let b = V[(i + 1) % V.count]
        let edge = _Segment(start: a, end: b)
        switch intersect(seg, edge, epsilon: epsilon) {
        case .finite(let eh, _, let rel):
            let kind: HitKind = (rel == .tangentContact) ? .tangent : .crossing
            for h in eh {
                hits.append(Hit(point: h.point,
                                kind: kind,
                                tA: h.tA, tB: h.tB,
                                featureA: .edge(-1), // segment has implicit single edge
                                featureB: .edge(i)))
            }

        case .infinite(let ov, _):
            spans.append(Span(featureA: .edge(-1), rangeA: ov.a,
                              featureB: .edge(i), rangeB: ov.b))

        case .none:
            break
        }
    }

    if !spans.isEmpty { return .finite(hits: hits, spans: spans, relation: .coincident) }
    if !hits.isEmpty { return .finite(hits: hits, relation: .properIntersect) }

    // 2) No boundary contacts — containment?
    let insideA = _pointInPolygon(seg.start, V, epsilon: epsilon)
    let insideB = _pointInPolygon(seg.end, V, epsilon: epsilon)
    if insideA && insideB { return .finite(hits: [], relation: .containment) }

    return .none()
}

// Local lightweight segment wrapper for polygon edges
private struct _Segment: _SegmentLike { let start: CGPoint; let end: CGPoint }

// Point-in-polygon: winding via ray casting; on-edge => inside
private func _pointInPolygon(_ p: CGPoint, _ verts: [CGPoint], epsilon: CGFloat) -> Bool {
    // quick on-edge test
    for i in 0..<verts.count {
        let a = verts[i]; let b = verts[(i + 1) % verts.count]
        if approxZero(cross(b - a, p - a), eps: epsilon) && dot(p - a, p - b) <= 0 { return true }
    }
    var inside = false
    for i in 0..<verts.count {
        let a = verts[i]; let b = verts[(i + 1) % verts.count]
        let condY = (a.y > p.y) != (b.y > p.y)
        if condY {
            let xi = a.x + (b.x - a.x) * (p.y - a.y) / ((b.y - a.y) + 1e-300)
            if p.x < xi { inside.toggle() }
        }
    }
    return inside
}

import SwiftUI

struct DragHandle: View {
    @Binding
    var position: CGPoint

    var body: some View {
        SwiftUI.Circle()
            .fill(Color.blue)
            .frame(width: 10, height: 10)
            .position(position)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        position = value.location
                    }
            )
    }
}

#Preview {
    @Previewable
    @State
    var circleCenter = CGPoint(x: 150, y: 150)

    @Previewable
    @State
    var circleEdgePoint = CGPoint(x: 200, y: 150)

    @Previewable
    @State
    var segmentVertex0 = CGPoint(x: 100, y: 100)

    @Previewable
    @State
    var segmentVertex1 = CGPoint(x: 250, y: 100)

    @Previewable
    @State
    var circle = Circle(center: CGPoint(x: 150, y: 150), radius: 50)

    @Previewable
    @State
    var segment = LineSegment(start: CGPoint(x: 100, y: 100), end: CGPoint(x: 250, y: 100))

    @Previewable
    @State
    var intersection: Intersection<CGFloat, CGFloat>?

    VStack {
        ZStack {
            Canvas { context, _ in
                context.stroke(Path(representable: circle), with: .color(.red), lineWidth: 2)
                let segment = LineSegment(start: segmentVertex0, end: segmentVertex1)
                context.stroke(Path(representable: segment), with: .color(.green), lineWidth: 2)

                if let intersection {
                    var marks: [CGPoint] = []
                    switch intersection {
                    case .none(let closest, let separation, let relation):
                        if let closest {
                            marks = [closest.a, closest.b]
                        }

                    case .finite(let hits, let spans, let relation):
                        marks = hits.map(\.point)

                    case .infinite(let overlap, let relation):
                        break
                    }
                    for mark in marks {
                        context.fill(Path(ellipseIn: CGRect(origin: mark - CGPoint(x: 5, y: 5), size: CGSize(width: 10, height: 10))), with: .color(.purple))
                    }
                }
            }
            .onChange(of: Composite(circleCenter, circleEdgePoint)) {
                circle = Circle(center: circleCenter, radius: circleEdgePoint.distance(to: circleCenter))
                intersection = intersect(segment, circle)
            }
            .onChange(of: Composite(segmentVertex0, segmentVertex1)) {
                segment = LineSegment(start: segmentVertex0, end: segmentVertex1)
                intersection = intersect(segment, circle)
            }
            .onChange(of: circleCenter) { old, new in
                let delta = new - old
                circleEdgePoint = circleEdgePoint + delta
            }

            DragHandle(position: $circleCenter)
            DragHandle(position: $circleEdgePoint)
            DragHandle(position: $segmentVertex0)
            DragHandle(position: $segmentVertex1)
        }

        if let intersection {
            Text("\(intersection)")
        }
    }
}
