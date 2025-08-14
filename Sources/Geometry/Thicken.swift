import Collections
import CoreGraphics
import SwiftUI

public func thicken(segments: [LineSegment], lineWidth: CGFloat, tolerance _: CGFloat) -> [CappedLineSegment] {
    print("#######################################")
    var segments = segments
    print("#raw segments", segments.count)
    segments = segments.filter { $0.length > 1e-06 }
    print("#long enough segments", segments.count)
    segments = segments.map { $0.sorted() }.uniqued()
    print("#unique segments", segments.count)

    let junctions = Junction.findJunctions(lineSegments: segments, epsilon: 0)
    return thicken(junctions: junctions, lineWidth: lineWidth, miterLimit: nil)
}

// MARK: -

public func thicken(junctions: [Junction], lineWidth: CGFloat, miterLimit _: CGFloat?) -> [CappedLineSegment] {
    print("#junctions", junctions.count)
    print("#junction vertices", junctions.map(\.vertices.count).reduce(0, +))
    let junctions = junctions.map { $0.normalized() }
    print("#normalized junction vertices", junctions.map(\.vertices.count).reduce(0, +))

    // Break each junction into N capped line segments.
    let cappedLineSegments = junctions.flatMap { junction in
        thicken(junction: junction, lineWidth: lineWidth, miterLimit: nil)
    }
    let cappedLineSegmentsBySegment = OrderedDictionary(uniqueKeysWithValues: cappedLineSegments.map { ($0.segment, $0) })

    var result: OrderedDictionary<UndirectedLineSegment, CappedLineSegment> = [:]
    for cappedSegment in cappedLineSegments where result[UndirectedLineSegment(cappedSegment.segment)] == nil {
        if let other = cappedLineSegmentsBySegment[cappedSegment.segment.reversed()] {
            var cappedSegment = cappedSegment
            cappedSegment = cappedSegment.takingCaps(from: other)
            result[UndirectedLineSegment(cappedSegment.segment)] = cappedSegment
        } else {
            result[UndirectedLineSegment(cappedSegment.segment)] = cappedSegment
        }
    }

    return Array(result.values)

    //    let thickenedLineSegmentsByCenter = OrderedDictionary(uniqueKeysWithValues: junctions.map { ($0.center, thicken(junction: $0, lineWidth: lineWidth, miterLimit: nil)) })
    //    var cappedLineSegments: OrderedDictionary<UndirectedLineSegment, CappedLineSegment> = [:]
    //    for thickenedLineSegments in thickenedLineSegmentsByCenter.values {
    //        for thickenedLineSegment in thickenedLineSegments {
    //            let key = UndirectedLineSegment(thickenedLineSegment.segment)
    //            guard cappedLineSegments[key] == nil else {
    //                continue
    //            }
    //            if let oppositeSegment = thickenedLineSegmentsByCenter[thickenedLineSegment.end] {
    //                let lhs = thickenedLineSegment
    //                let rhs = oppositeSegment
    //                var mergedSegment = CappedLineSegment(start: thickenedLineSegment.start,end: thickenedLineSegment.end,width: thickenedLineSegment.width)
    //                mergedSegment = mergedSegment.takingCaps(from: lhs)
    ////                mergedSegment = mergedSegment.takingCaps(from: rhs)
    //                cappedLineSegments[key] = mergedSegment
    //            }
    //            else {
    //                cappedLineSegments[key] = thickenedLineSegment
    //            }
    //        }
    //    }
    //    print("#cappedLineSegments", cappedLineSegments.count)
    //    return Array(cappedLineSegments.values)
    return []
}

public func thicken(junction: Junction, lineWidth: CGFloat, miterLimit _: CGFloat?) -> [CappedLineSegment] {
    guard junction.vertices.count > 1 else {
        return [CappedLineSegment(start: junction.center, end: junction.vertices[0], width: lineWidth)]
    }
    let center = junction.center
    var result = junction.vertices.map { vertex in
        CappedLineSegment(start: center, end: vertex, width: lineWidth)
    }

    for currentIndex in 0..<(junction.vertices.count) {
        let nextIndex = (currentIndex + 1) % junction.vertices.count

        let currentVertex = junction.vertices[currentIndex]
        let nextVertex = junction.vertices[nextIndex]

        let line1 = Line(p1: center, p2: currentVertex).parallelTo(lineWidth / 2)
        let line2 = Line(p1: center, p2: nextVertex).parallelTo(-lineWidth / 2)

        GeometryLog.shared.log(geometries: [.line(line1), .line(line2)])

        guard let intersection = line1.intersection(with: line2) else {
            continue
        }

        GeometryLog.shared.log(geometries: [.point(intersection)])

        result[currentIndex].set(point: intersection, at: 2, endPoint: center)
        result[currentIndex].startOffsets.2 = max(result[currentIndex].startOffsets.2, -result[currentIndex].segment.length)
        result[nextIndex].set(point: intersection, at: 0, endPoint: center)
        result[nextIndex].startOffsets.0 = max(result[nextIndex].startOffsets.0, -result[nextIndex].segment.length)
    }

    return result
}
// MARK: -

extension CappedLineSegment {
    /// Sets the point at the specified index, adjusting the start or end point based on the provided endPoint.
    mutating func set(point: CGPoint, at index: Int, endPoint: CGPoint) {
        // TOOD: JIW SANITY CHECK
        // assert(CGRect(center: .zero, radius: 20).contains(point), "Point \(point) is outside the expected bounds")

        if endPoint == start {
            set(point: point, at: index)
        } else if endPoint == end {
            set(point: point, at: index + 3)
        } else {
            fatalError("Neitther start (\(start)) nor end (\(end) point match query \(endPoint)")
        }
    }

    func offsets(for point: CGPoint) -> (CGFloat, CGFloat, CGFloat) {
        if point == start {
            return startOffsets
        }
        if point == end {
            return endOffsets
        }
        fatalError()
    }

    func takingCaps(from other: CappedLineSegment) -> CappedLineSegment {
        var copy = self
        if copy.start == other.start {
            copy.startCap = other.startCap
        }
        if copy.end == other.end {
            copy.endCap = other.endCap
        }
        return copy
    }
}
