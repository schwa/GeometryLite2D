#if canImport(CoreGraphics)
import CoreGraphics
#else
import Foundation
#endif
import Numerics

// MARK: - Computed Properties

public extension Polyline {
    // TODO: Make property Call "segments" instead.
    func lineSegments() -> [LineSegment] {
        guard vertices.count > 1 else { return [] }
        var segments: [LineSegment] = []
        for i in 0..<vertices.count - 1 {
            let segment = LineSegment(start: vertices[i], end: vertices[i + 1])
            segments.append(segment)
        }
        return segments
    }
}

// MARK: - Factory Methods

public extension Polyline {
    static func polylines(from lineSegments: [LineSegment], absoluteTolerance: CGFloat = 0) -> [Polyline] {
        // Helper to compare points with optional absoluteTolerance
        // TODO: Just use isApproximatelyEqual
        func pointsEqual(_ a: CGPoint, _ b: CGPoint) -> Bool {
            if absoluteTolerance == 0 {
                return a == b
            }
            return a.distance(to: b).isApproximatelyEqual(to: 0, absoluteTolerance: absoluteTolerance)
        }
        
        var remainingSegments = lineSegments
        var polylines: [Polyline] = []
        
        while !remainingSegments.isEmpty {
            let current = remainingSegments.removeFirst()
            var vertices = [current.start, current.end]
            
            var extended = true
            while extended {
                extended = false
                for (i, seg) in remainingSegments.enumerated() {
                    if pointsEqual(seg.start, vertices.last!) {
                        vertices.append(seg.end)
                        remainingSegments.remove(at: i)
                        extended = true
                        break
                    }
                    if pointsEqual(seg.end, vertices.last!) {
                        vertices.append(seg.start)
                        remainingSegments.remove(at: i)
                        extended = true
                        break
                    }
                    if pointsEqual(seg.end, vertices.first!) {
                        vertices.insert(seg.start, at: 0)
                        remainingSegments.remove(at: i)
                        extended = true
                        break
                    }
                    if pointsEqual(seg.start, vertices.first!) {
                        vertices.insert(seg.end, at: 0)
                        remainingSegments.remove(at: i)
                        extended = true
                        break
                    }
                }
            }
            
            polylines.append(Polyline(vertices: vertices))
        }
        
        return polylines
    }
}

// MARK: - Validation Methods

public extension Polyline {
    func isClosed(absoluteTolerance: CGFloat = 0) -> Bool {
        guard vertices.count > 1 else { return false }
        return vertices.first!.isApproximatelyEqual(to: vertices.last!, absoluteTolerance: absoluteTolerance)
    }
    
    func containsLoops(absoluteTolerance: CGFloat = 0) -> Bool {
        guard vertices.count > 1 else { return false }
        let last = vertices.last!
        for i in 0..<(vertices.count - 1) {
            if last.isApproximatelyEqual(to: vertices[i], absoluteTolerance: absoluteTolerance) {
                return true
            }
        }
        return false
    }
}
