import CoreGraphics

// TODO: This needs a better name

/// Resolves T-junctions in a collection of line segments by splitting segments at intersection points within a given tolerance.
///
/// - Parameters:
///   - segments: An array of `LineSegment` objects to process for T-junctions.
///   - absoluteTolerance: The maximum allowed distance between endpoints and segment lines to consider as a T-junction.
///   - maxIterations: The maximum number of iterations to attempt resolving T-junctions.
/// - Returns: A dictionary mapping each original `LineSegment` to an array of resulting `LineSegment`s after T-junction resolution.
public func resolveTJunctions(segments: [LineSegment], absoluteTolerance: CGFloat, maxIterations: Int = 20) -> [LineSegment: [LineSegment]] {
    // Initialize the mapping from original segments to themselves
    var segmentMap: [LineSegment: [LineSegment]] = [:]
    for segment in segments {
        segmentMap[segment] = [segment]
    }
    var changed = true
    var iteration = 0
    while changed && iteration < maxIterations {
        changed = false
        var newMap: [LineSegment: [LineSegment]] = [:]
        for (original, subSegments) in segmentMap {
            var updatedSubsegments: [LineSegment] = []
            for segment in subSegments {
                var splits = [segment]
                for (_, otherSegments) in segmentMap {
                    for other in otherSegments {
                        for point in [other.start, other.end] {
                            if segment.contains(point, interior: true, absoluteTolerance: absoluteTolerance) {
                                let splitResult = splits.flatMap { $0.split(at: point) }
                                if splitResult.count > 1 {
                                    changed = true
                                }
                                splits = splitResult
                            }
                        }
                    }
                }

                updatedSubsegments.append(contentsOf: splits)
            }
            newMap[original] = updatedSubsegments.uniqued()
        }
        segmentMap = newMap
        iteration += 1
    }

    if iteration == maxIterations {
        print("Warning: max T-junction resolution iterations reached.")
    }

    return segmentMap
}
