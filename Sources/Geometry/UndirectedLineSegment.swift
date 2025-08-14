import CoreGraphics

public struct UndirectedLineSegment: Hashable, Sendable {
    let v0: CGPoint
    let v1: CGPoint

    public init(v0: CGPoint, v1: CGPoint) {
        if v0.compare(to: v1, using: .yThenX) == .orderedAscending {
            self.v0 = v0
            self.v1 = v1
        } else {
            self.v0 = v1
            self.v1 = v0
        }
    }
}