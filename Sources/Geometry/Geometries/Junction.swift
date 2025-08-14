import CoreGraphics

public struct Junction {
    public let center: CGPoint
    public let vertices: [CGPoint]

    public init(center: CGPoint, vertices: [CGPoint]) {
        self.center = center
        // Deduplicate vertices
        let uniqueVertices = Array(Set(vertices))
        // Sort vertices by angle from center
        self.vertices = uniqueVertices.sorted { lhs, rhs in
            let lhsAngle = atan2(lhs.y - center.y, lhs.x - center.x)
            let rhsAngle = atan2(rhs.y - center.y, rhs.x - center.x)
            return lhsAngle < rhsAngle
        }
    }
}

extension Junction: Equatable {
    public static func == (lhs: Junction, rhs: Junction) -> Bool {
        // Since vertices are already sorted in init, we can directly compare
        return lhs.center == rhs.center && lhs.vertices == rhs.vertices
    }
}

extension Junction: Hashable {
}

extension Junction: Sendable {
}

public extension Junction {
    func ordered() -> Junction {
        Junction(center: center, vertices: vertices.sorted { lhs, rhs in
            let lhsAngle = center.angle(relativeTo: lhs)
            let rhsAngle = center.angle(relativeTo: rhs)
            return lhsAngle < rhsAngle
        })
    }

    func normalized() -> Junction {
        Junction(center: center, vertices: vertices.uniqued()).ordered()
    }
}

public extension Junction {
    var segments: [LineSegment] {
        vertices.map { vertex in
            LineSegment(start: center, end: vertex)
        }
    }
}

public extension Junction {
    /// Finds and returns all junctions (intersection points) among the given line segments within a specified tolerance.
    /// This function does not break line segments up at T-junctions or intersections, but rather identifies junctions based on proximity of endpoints and intersection points.
    ///
    /// - Parameters:
    ///   - lineSegments: An array of `LineSegment` objects to analyze for junctions.
    ///   - absoluteTolerance: The maximum distance between endpoints or intersection points to consider them as a single junction.
    /// - Returns: An array of `Junction` objects representing the detected junctions among the provided line segments.
    static func findJunctions(lineSegments: [LineSegment], absoluteTolerance: CGFloat) -> [Junction] {
        let lineSegments = lineSegments.filter { !$0.start.isApproximatelyEqual(to: $0.end, absoluteTolerance: absoluteTolerance) }
        // Flatten endpoints with reference to their segments
        var endpoints: [(point: CGPoint, segment: LineSegment, isStart: Bool)] = []
        for segment in lineSegments {
            endpoints.append((segment.start, segment, true))
            endpoints.append((segment.end, segment, false))
        }
        // Group points by proximity (naive clustering)
        var clusters: [[(point: CGPoint, segment: LineSegment, isStart: Bool)]] = []
        for entry in endpoints {
            if let i = clusters.firstIndex(where: { cluster in
                cluster.contains(where: { $0.point.distance(to: entry.point) <= absoluteTolerance })
            }) {
                clusters[i].append(entry)
            } else {
                clusters.append([entry])
            }
        }
        // Build junctions - only where multiple segments meet
        var result: [Junction] = []
        for cluster in clusters {
            // Only create a junction if multiple segments meet at this point
            let uniqueSegments = Set(cluster.map(\.segment))
            if uniqueSegments.count < 2 {
                continue // Skip if only one segment has endpoints here
            }
            
            // Average cluster center
            let center = cluster.map(\.point).reduce(.zero, +) / CGFloat(cluster.count)
            // Collect opposite endpoints of each line segment
            var vertices: [CGPoint] = []
            for entry in cluster {
                let other = entry.isStart ? entry.segment.end : entry.segment.start
                vertices.append(other)
            }
            vertices = vertices.filter { !$0.isApproximatelyEqual(to: center, absoluteTolerance: absoluteTolerance) }
            result.append(Junction(center: center, vertices: vertices))
        }
        return result
    }
}
