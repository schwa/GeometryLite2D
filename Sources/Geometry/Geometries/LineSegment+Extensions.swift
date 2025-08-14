#if canImport(CoreGraphics)
import CoreGraphics
#else
import Foundation
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

// MARK: - Convenience Initializers

public extension LineSegment {
    init(_ start: CGPoint, _ end: CGPoint) {
        self.start = start
        self.end = end
    }
}

// MARK: - Computed Properties

public extension LineSegment {
    var points: [CGPoint] {
        [start, end]
    }
    
    var mid: CGPoint {
        (start + end) / 2
    }
    
    var length: CGFloat {
        (end - start).length
    }
    
    var angle: Angle {
        Angle(radians: atan2(end.y - start.y, end.x - start.x))
    }
    
    func reversed() -> LineSegment {
        LineSegment(end, start)
    }
    
    func sorted() -> LineSegment {
        if start.compare(to: end, using: .yThenX) == .orderedAscending {
            return self
        } else {
            return reversed()
        }
    }
    
    func split(at point: CGPoint) -> [LineSegment] {
        if !contains(point, absoluteTolerance: 1e-5) {
            return [self]
        }
        if point == start || point == end {
            return [self]
        }
        return [
            LineSegment(start, point),
            LineSegment(point, end)
        ]
    }
    
    var direction: CGVector {
        CGVector((end - start).normalized)
    }
    
    var normal: CGVector {
        direction.perpendicular.normalized
    }
    
    var vector: CGVector {
        CGVector(end - start)
    }
    
    func parallel(by offset: CGFloat) -> LineSegment {
        let n = self.normal * offset
        return .init(start: start + n, end: end + n)
    }
    
    func removing(lineSegment: LineSegment) -> [LineSegment] {
        guard start != end else {
            fatalError("Degenerate line segment")
        }
        if self == lineSegment {
            return []
        }
        
        let axis = (end - start).normalized
        let length = (end - start).length
        
        // Function to project a point onto this segment's axis
        func project(_ point: CGPoint) -> CGFloat {
            (point - start).dot(axis)
        }
        
        let selfStartScalar: CGFloat = 0
        let selfEndScalar: CGFloat = length
        
        let otherStart = project(lineSegment.start)
        let otherEnd = project(lineSegment.end)
        
        let removalStart = max(min(otherStart, otherEnd), selfStartScalar)
        let removalEnd = min(max(otherStart, otherEnd), selfEndScalar)
        
        // No overlap
        if removalStart >= removalEnd {
            return [self]
        }
        
        var result: [LineSegment] = []
        
        if removalStart > selfStartScalar {
            let segmentStart = start
            let segmentEnd = start + axis * removalStart
            result.append(LineSegment(start: segmentStart, end: segmentEnd))
        }
        
        if removalEnd < selfEndScalar {
            let segmentStart = start + axis * removalEnd
            let segmentEnd = end
            result.append(LineSegment(start: segmentStart, end: segmentEnd))
        }
        
        return result
    }
    
    func removing(lineSegments: [LineSegment]) -> [LineSegment] {
        var remainingSegments: [LineSegment] = [self]
        for segmentToRemove in lineSegments {
            remainingSegments = remainingSegments.flatMap { $0.removing(lineSegment: segmentToRemove) }
        }
        return remainingSegments
    }
    
    func sharesVertex(with other: LineSegment, absoluteTolerance: CGFloat = 1e-5) -> Bool {
        self.start.isApproximatelyEqual(to: other.start, absoluteTolerance: absoluteTolerance) ||
            self.start.isApproximatelyEqual(to: other.end, absoluteTolerance: absoluteTolerance) ||
            self.end.isApproximatelyEqual(to: other.start, absoluteTolerance: absoluteTolerance) ||
            self.end.isApproximatelyEqual(to: other.end, absoluteTolerance: absoluteTolerance)
    }
    
    func isTJunction(with other: LineSegment, epsilon: CGFloat = 1e-5) -> Bool {
        // Check if one of the endpoints of `other` lies on this segment (interior only)
        let otherStartOnSelf = self.contains(other.start, interior: true, absoluteTolerance: epsilon)
        let otherEndOnSelf = self.contains(other.end, interior: true, absoluteTolerance: epsilon)
        // A T-junction occurs if exactly one endpoint of `other` lies on this segment (interior only)
        return (otherStartOnSelf != otherEndOnSelf) && (otherStartOnSelf || otherEndOnSelf)
    }
}

extension LineSegment: CustomDebugStringConvertible {
    public var debugDescription: String {
        let format = FloatingPointFormatStyle<Double>().precision(.fractionLength(4))
        return "[\(start.x.formatted(format)), \(start.y.formatted(format)), \(end.x.formatted(format)), \(end.y.formatted(format))]"
    }
}

public extension LineSegment {
    init(center: CGPoint, width: CGFloat, direction: CGVector) {
        let halfWidth = width / 2
        let p1 = CGPoint(x: center.x + direction.dx * halfWidth, y: center.y + direction.dy * halfWidth)
        let p2 = CGPoint(x: center.x - direction.dx * halfWidth, y: center.y - direction.dy * halfWidth)
        self.init(start: p1, end: p2)
    }
}
