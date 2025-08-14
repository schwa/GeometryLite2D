import CoreGraphics

public struct Line {
    public var point: CGPoint         // A point on the line
    public var direction: CGVector    // A non-zero direction vector

    public init(point: CGPoint, direction: CGVector) {
        precondition(direction.dx != 0 || direction.dy != 0, "Direction vector cannot be zero")
        self.point = point
        self.direction = direction
    }
}

extension Line: Equatable {
}

extension Line: Hashable {
}

extension Line: Sendable {
}
