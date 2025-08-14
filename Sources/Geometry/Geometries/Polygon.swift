#if canImport(CoreGraphics)
import CoreGraphics
#else
import Foundation
#endif

public struct Polygon {
    public var vertices: [CGPoint] {
        willSet {
            assert(vertices.count >= 3, "A polygon must have at least 3 vertices")
        }
    }

    public init(_ vertices: [CGPoint]) {
        // TODO: Sanity check
        assert(vertices.count >= 3, "A polygon must have at least 3 vertices")
        self.vertices = vertices
    }
}

extension Polygon: Equatable {
}

extension Polygon: Hashable {
}

extension Polygon: Sendable {
}

// An ugly alias to help with name collisions
public typealias Polygon_ = Polygon