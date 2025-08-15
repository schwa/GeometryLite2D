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

#if canImport(Playgrounds)
import Playgrounds
import Visualization

#Playground {
    let c = Circle(center: [10, 10], radius: 10)
    visualize([c])
}
#endif

