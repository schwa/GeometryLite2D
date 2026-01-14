import CoreGraphics

/// Options for controlling segment splitting behavior.
public struct SplitOptions: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Split segments at T-junctions (where an endpoint of one segment lies on another segment's interior)
    public static let tJunctions = SplitOptions(rawValue: 1 << 0)

    /// Split segments at crossing intersections (where two segments cross but neither endpoint is at the intersection)
    public static let crossings = SplitOptions(rawValue: 1 << 1)

    /// Split at both T-junctions and crossings
    public static let all: SplitOptions = [.tJunctions, .crossings]
}

/// Resolves segment intersections by splitting segments at intersection points within a given tolerance.
///
/// - Parameters:
///   - segments: An array of `LineSegment` objects to process.
///   - options: Controls what types of intersections to split at.
///   - absoluteTolerance: The maximum allowed distance between endpoints and segment lines to consider as a T-junction.
///   - maxIterations: The maximum number of iterations to attempt resolving intersections.
/// - Returns: A dictionary mapping each original `LineSegment` to an array of resulting `LineSegment`s after resolution.
public func resolveTJunctions(segments: [LineSegment], options: SplitOptions = .tJunctions, absoluteTolerance: CGFloat, maxIterations: Int = 20) -> [LineSegment: [LineSegment]] {
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
                        // T-junctions: split at endpoints of other segments
                        if options.contains(.tJunctions) {
                            for point in [other.start, other.end] {
                                if segment.contains(point, interior: true, absoluteTolerance: absoluteTolerance) {
                                    let splitResult = splits.flatMap { $0.split(at: point, absoluteTolerance: absoluteTolerance) }
                                    if splitResult.count > splits.count {
                                        changed = true
                                    }
                                    splits = splitResult
                                }
                            }
                        }

                        // Crossings: split at intersection points
                        if options.contains(.crossings) {
                            if segment != other {
                                for s in splits {
                                    if let intersection = s.intersection(other) {
                                        // Only split if intersection is interior to both segments
                                        if s.contains(intersection, interior: true, absoluteTolerance: absoluteTolerance) {
                                            let splitResult = splits.flatMap { $0.split(at: intersection, absoluteTolerance: absoluteTolerance) }
                                            if splitResult.count > splits.count {
                                                changed = true
                                            }
                                            splits = splitResult
                                        }
                                    }
                                }
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
        // Warning: max T-junction resolution iterations reached
    }

    return segmentMap
}
