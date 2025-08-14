import CoreGraphics

public struct Circle {
    public var center: CGPoint
    public var radius: CGFloat

    public init(center: CGPoint, radius: CGFloat) {
        self.center = center
        self.radius = radius
    }
}

extension Circle: Equatable {
}

extension Circle: Hashable {
}

extension Circle: Sendable {
}

public typealias Circle_ = Circle
