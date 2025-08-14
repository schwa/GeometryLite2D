import CoreGraphics

public struct Ray {
    public var origin: CGPoint
    public var direction: CGVector  // Should be non-zero

    public init(origin: CGPoint, direction: CGVector) {
        precondition(direction.dx != 0 || direction.dy != 0, "Direction vector cannot be zero.")
        self.origin = origin
        self.direction = direction
    }
}

extension Ray: Equatable {
}

extension Ray: Hashable {
}

extension Ray: Sendable {
}