import CoreGraphics
import Geometry

public extension Polygon_ {
    /// Creates a polygon from a collection of line segments that form a closed loop.
    /// - Parameter segments: Line segments that should form a closed polygon
    /// - Returns: A polygon if the segments form a valid closed loop, nil otherwise
    init?(segments: [LineSegment]) {
        guard !segments.isEmpty else {
            return nil
        }

        // Build a map from points to connected segments
        var adjacency: [CGPoint: [LineSegment]] = [:]
        for segment in segments {
            adjacency[segment.start, default: []].append(segment)
            adjacency[segment.end, default: []].append(segment)
        }

        // In a simple closed polygon, each point should be connected to exactly two segments
        for (_, connectedSegments) in adjacency {
            if connectedSegments.count != 2 {
                return nil
            }
        }

        // Start reconstructing the polygon from any segment
        var orderedPoints: [CGPoint] = []
        var usedSegments: Set<LineSegment> = []
        var currentSegment = segments[0]
        var currentPoint = currentSegment.start
        orderedPoints.append(currentPoint)

        while usedSegments.count < segments.count {
            usedSegments.insert(currentSegment)
            let nextPoint = currentSegment.start == currentPoint ? currentSegment.end : currentSegment.start

            // Check if we've completed the loop
            if nextPoint == orderedPoints[0] {
                break
            }

            orderedPoints.append(nextPoint)

            // Find the next segment that connects to nextPoint and isn't already used
            let connectedSegments = adjacency[nextPoint] ?? []
            let unusedConnectedSegments = connectedSegments.filter { !usedSegments.contains($0) }

            if unusedConnectedSegments.isEmpty {
                // We've reached a dead end
                return nil
            }

            currentSegment = unusedConnectedSegments[0]
            currentPoint = nextPoint
        }

        // Verify we used all segments
        if usedSegments.count < segments.count {
            // Disconnected loops
            return nil
        }

        // A polygon should have at least 3 vertices
        guard orderedPoints.count >= 3 else {
            return nil
        }

        self.init(orderedPoints)
    }
}
