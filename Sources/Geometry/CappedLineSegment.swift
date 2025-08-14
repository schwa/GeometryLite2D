import CoreGraphics
import SwiftUI

/*

 When both caps are `butt` the vertices are in this order. 1 & 4 are start and end vertices of the segment:

 >                   0------------------------------5
 >                   |                              |
 >                   1                              4
 >                   |                              |
 >                   2------------------------------3

 When caps are `mitered` the vertices are in this order. 1 & 4 may or may not be start and end vertices of the segment:


 >                      0------------------------------5
 >                     /                              /
 >                    1                              4
 >                   /                              /
 >                  2------------------------------3
 */

/**
 A `CappedLineSegment` represents a line segment with additional properties for width and customizable end caps.

 - Properties:
 - `start`: The starting point of the line segment.
 - `end`: The ending point of the line segment.
 - `width`: The width of the line segment.
 - `startCap`: The style of the cap at the start of the segment.
 - `endCap`: The style of the cap at the end of the segment.

 - Cap Styles:
 - `butt`: A flat cap that does not extend beyond the segment.
 - `square`: A square cap that extends half the width beyond the segment.
 - `mitered`: A cap with three points forming a mitered edge.
 */
public struct CappedLineSegment: Equatable {
    public enum Cap: Equatable {
        public enum BevelVertex: Equatable {
            case first
            case second
        }
        case butt
        case square
        // TODO: Mitered is really overly specific. It should be renamed to "general"?
        case mitered(CGFloat, CGFloat, CGFloat) // Distances from the butt vertices and the center of the butt
        // TODO: Bevel is just a special case of mitered.
        case bevel(BevelVertex, CGFloat) // Vertex index and distance from the vertex to the bevel point
    }

    public var start: CGPoint
    public var end: CGPoint

    public var width: CGFloat
    public var startCap: Cap // TODO: Make Cap optional
    public var endCap: Cap

    public init(start: CGPoint, end: CGPoint, width: CGFloat, startCap: Cap = .butt, endCap: Cap = .butt) {
        self.start = start
        self.end = end
        self.width = width
        self.startCap = startCap
        self.endCap = endCap
    }
}

public extension CappedLineSegment {
    init(segment: LineSegment, width: CGFloat, startCap: Cap = .butt, endCap: Cap = .butt) {
        self.init(start: segment.start, end: segment.end, width: width, startCap: startCap, endCap: endCap)
    }

    var segment: LineSegment {
        get {
            .init(start: start, end: end)
        }
        set {
            start = newValue.start
            end = newValue.end
        }
    }

    var direction: CGVector {
        segment.direction
    }

    var normal: CGVector {
        segment.normal
    }

    var startOffsets: (CGFloat, CGFloat, CGFloat) {
        get {
            switch startCap {
            case .butt:
                return (0, 0, 0)

            case .square:
                return (width / 2, width / 2, width / 2)

            case .mitered(let d0, let d1, let d2):
                return (d0, d1, d2)

            case .bevel(let index, let distance):
                return (index == .first ? -distance : 0, 0, index == .second ? -distance : 0)
            }
        }
        set {
            switch newValue {
            case (0, 0, 0):
                startCap = .butt

            case (width / 2, width / 2, width / 2):
                startCap = .square

            default:
                if newValue.1 == 0 && newValue.0 == 0 {
                    startCap = .bevel(.second, -newValue.2)
                } else if newValue.1 == 0 && newValue.2 == 0 {
                    startCap = .bevel(.first, -newValue.0)
                } else {
                    startCap = .mitered(newValue.0, newValue.1, newValue.2)
                }
            }
        }
    }

    var endOffsets: (CGFloat, CGFloat, CGFloat) {
        get {
            switch endCap {
            case .butt:
                return (0, 0, 0)

            case .square:
                return (width / 2, width / 2, width / 2)

            case .mitered(let d0, let d1, let d2):
                return (d0, d1, d2)

            case .bevel(let index, let distance):
                return (index == .first ? -distance : 0, 0, index == .second ? -distance : 0)
            }
        }
        set {
            switch newValue {
            case (0, 0, 0):
                endCap = .butt

            case (width / 2, width / 2, width / 2):
                endCap = .square

            default:
                if newValue.1 == 0 && newValue.0 == 0 {
                    endCap = .bevel(.second, -newValue.2)
                } else if newValue.1 == 0 && newValue.2 == 0 {
                    endCap = .bevel(.first, -newValue.0)
                } else {
                    endCap = .mitered(newValue.0, newValue.1, newValue.2)
                }
            }
        }
    }
}

public extension CappedLineSegment {
    var vertices: [CGPoint] {
        get {
            let direction = direction.normalized
            let halfNormalWidth = normal * width / 2
            let p0 = start - direction * startOffsets.0 - halfNormalWidth
            let p1 = start - direction * startOffsets.1
            let p2 = start - direction * startOffsets.2 + halfNormalWidth
            let p3 = end + direction * endOffsets.0 + halfNormalWidth
            let p4 = end + direction * endOffsets.1
            let p5 = end + direction * endOffsets.2 - halfNormalWidth
            return [p0, p1, p2, p3, p4, p5]
        }
    }

    var polygon: Polygon_ {
        Polygon_(vertices)
    }

    mutating func set(point: CGPoint, at index: Int) {
        precondition((0..<6).contains(index), "Index must be between 0 and 5")
        let direction = direction.normalized
        if index < 3 {
            // Start cap
            let offset = (point - start).dot(CGPoint(-direction))
            switch index {
            case 0: startOffsets.0 = offset
            case 1: startOffsets.1 = offset
            case 2: startOffsets.2 = offset
            default: break
            }
        } else {
            // End cap
            let offset = (point - end).dot(CGPoint(direction))
            switch index {
            case 3: endOffsets.0 = offset
            case 4: endOffsets.1 = offset
            case 5: endOffsets.2 = offset
            default: break
            }
        }
    }

    func mitered(from points: (CGPoint, CGPoint, CGPoint), for vertex: CGPoint) -> CappedLineSegment {
        // TODO: This couuld easily use set() above.
        let cap = computeMiterCap(from: points, for: vertex)
        switch vertex {
        case start:
            return CappedLineSegment(start: start, end: end, width: width, startCap: cap, endCap: endCap)

        case end:
            return CappedLineSegment(start: start, end: end, width: width, startCap: startCap, endCap: cap)

        default:
            fatalError("TODO")
        }
    }

    func computeMiterCap(from points: (CGPoint, CGPoint, CGPoint), for vertex: CGPoint) -> Cap {
        let direction = self.direction.normalized

        // Project the vector from the vertex to each point onto the direction vector.
        func offset(for point: CGPoint) -> CGFloat {
            let vector = point - vertex
            return vector.dot(CGPoint(direction))
        }

        let d0 = offset(for: points.0)
        let d1 = offset(for: points.1)
        let d2 = offset(for: points.2)

        return .mitered(d0, d1, d2)
    }
}

extension CappedLineSegment.Cap: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .butt:
            return "butt"

        case .square:
            return "square"

        case .mitered(let offset0, let offset1, let offset2):
            return "mitered(\(offset0), \(offset1), \(offset2))"

        case .bevel(let index, let distance):
            return "bevel(index: \(index), distance: \(distance))"
        }
    }
}

public extension Path {
    init(_ segment: CappedLineSegment) {
        self = Path(segment.polygon)
    }
}

extension CappedLineSegment: Sendable {
}

extension CappedLineSegment.Cap: Sendable {
}

extension CappedLineSegment.Cap.BevelVertex: Sendable {
}
