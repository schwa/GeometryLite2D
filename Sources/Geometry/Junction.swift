import CoreGraphics

public struct Junction {
    public var center: CGPoint
    public var vertices: [CGPoint]

    public init(center: CGPoint, vertices: [CGPoint]) {
        self.center = center
        self.vertices = vertices
    }
}

extension Junction: Equatable {
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
    ///   - epsilon: The maximum distance between endpoints or intersection points to consider them as a single junction.
    /// - Returns: An array of `Junction` objects representing the detected junctions among the provided line segments.
    static func findJunctions(lineSegments: [LineSegment], epsilon: CGFloat) -> [Junction] {
        let lineSegments = lineSegments.filter { !$0.start.isApproximatelyEqual(to: $0.end, epsilon: epsilon) }
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
                cluster.contains(where: { $0.point.distance(to: entry.point) <= epsilon })
            }) {
                clusters[i].append(entry)
            } else {
                clusters.append([entry])
            }
        }
        // Build junctions
        var result: [Junction] = []
        for cluster in clusters {
            // Average cluster center
            let center = cluster.map(\.point).reduce(.zero, +) / CGFloat(cluster.count)
            // Collect opposite endpoints of each line segment
            var vertices: [CGPoint] = []
            for entry in cluster {
                let other = entry.isStart ? entry.segment.end : entry.segment.start
                vertices.append(other)
            }
            vertices = vertices.filter { !$0.isApproximatelyEqual(to: center, epsilon: epsilon) }
            result.append(Junction(center: center, vertices: vertices))
        }
        return result
    }
}
