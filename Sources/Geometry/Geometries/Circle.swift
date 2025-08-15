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
import SwiftUI

#Preview {
    let circle = Circle(center: CGPoint(x: 100, y: 100), radius: 50)
    let path = Path(representable: circle)
    path.stroke(Color.blue, lineWidth: 2)
}
#endif

