#if canImport(CoreGraphics)
import CoreGraphics
#else
import Foundation
#endif

public struct LineSegment {
    public var start: CGPoint
    public var end: CGPoint

    public init(start: CGPoint, end: CGPoint) {
        self.start = start
        self.end = end
    }
}

extension LineSegment: Equatable {
}

extension LineSegment: Hashable {
}

extension LineSegment: Sendable {
}
