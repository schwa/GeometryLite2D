import CoreGraphics
import Foundation
import Numerics

// Stable child IDs derived from parent IDs so repeated runs are deterministic.
public struct SplitID<ParentID: Hashable>: Hashable {
    public let parent: ParentID
    public let ordinal: Int
}

extension SplitID: CustomStringConvertible {
    public var description: String {
        "\(parent)/\(ordinal)"
    }
}

// MARK: - Splitter

/// Splits all segments at every intersection (including T-junctions).
/// - Parameters:
///   - segments: input segments, each identified by a parent ID
///   - epsilon: geometric tolerance for merging near-duplicate split params
/// - Returns: subsegments, each identified by `(parent, ordinal)`
public func split<ParentID: Hashable>(segments: [Identified<ParentID, LineSegment>], epsilon: CGFloat = 1e-9) -> [Identified<SplitID<ParentID>, LineSegment>] {
    // Helper: linear interpolation on a segment
    func point(on s: LineSegment, at t: CGFloat) -> CGPoint {
        CGPoint(
            x: s.start.x + (s.end.x - s.start.x) * t,
            y: s.start.y + (s.end.y - s.start.y) * t
        )
    }

    // Helper: numerical dedup with absoluteTolerance
    func uniqueSorted(_ values: [CGFloat], absoluteTolerance: CGFloat) -> [CGFloat] {
        let sorted = values.sorted()
        var out: [CGFloat] = []
        out.reserveCapacity(sorted.count)
        for v in sorted {
            if let last = out.last {
                if !v.isApproximatelyEqual(to: last, absoluteTolerance: absoluteTolerance) { out.append(v) }
            } else {
                out.append(v)
            }
        }
        return out
    }

    // 1) Collect split parameters per segment (always include 0 and 1)
    var splitParams: [[CGFloat]] = Array(repeating: [0, 1], count: segments.count)

    // Pairwise intersections
    for i in 0..<segments.count {
        for j in (i + 1)..<segments.count {
            let s1 = segments[i].value
            let s2 = segments[j].value

            switch segmentIntersection(s1, s2) {
            case .none:
                break

            case let .point(_, t1, t2):
                // record interior hits; endpoints are fine too (dedup handles them)
                splitParams[i].append(t1)
                splitParams[j].append(t2)
            }
        }
    }

    // 2) For each segment, sort + dedup, then emit subsegments between consecutive t's
    var result: [Identified<SplitID<ParentID>, LineSegment>] = []
    result.reserveCapacity(segments.count * 2) // rough guess

    for (idx, identifiedSeg) in segments.enumerated() {
        let s = identifiedSeg.value
        let parentID = identifiedSeg.id

        // sort & dedup with epsilon
        let ts = uniqueSorted(splitParams[idx], absoluteTolerance: epsilon)

        // build consecutive spans
        var ordinal = 0
        for k in 0..<(ts.count - 1) {
            let t0 = ts[k], t1 = ts[k + 1]
            // Avoid zero-length with tolerance
            if (t1 - t0) <= epsilon { continue }

            let a = point(on: s, at: t0)
            let b = point(on: s, at: t1)
            // Guard against numerical collapse
            if hypot(b.x - a.x, b.y - a.y) <= Double(epsilon) {
                continue
            }

            let child = LineSegment(a, b)
            let childID = SplitID(parent: parentID, ordinal: ordinal)
            result.append(Identified(id: childID, value: child))
            ordinal += 1
        }
    }

    return result
}
