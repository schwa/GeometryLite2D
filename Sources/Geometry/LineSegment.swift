#if canImport(CoreGraphics)
import CoreGraphics
#else
import Foundation
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(Glibc)
import Glibc
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

// MARK: -

public extension LineSegment {
    init(_ start: CGPoint, _ end: CGPoint) {
        self.start = start
        self.end = end
    }

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

    var direction: CGVector {
        CGVector((end - start).normalized)
    }

    var normal: CGVector {
        direction.perpendicular.normalized
    }
}

// MARK: -

public extension LineSegment {
    var vector: CGVector {
        CGVector(end - start)
    }
}
