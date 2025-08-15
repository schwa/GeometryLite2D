import CoreGraphics

// MARK: - Convenience Initializers

public extension UndirectedLineSegment {
    init(_ lineSegment: LineSegment) {
        self.init(v0: lineSegment.start, v1: lineSegment.end)
    }
}
