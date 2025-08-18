#if canImport(CoreGraphics)
import CoreGraphics
#else
import Foundation
#endif

public struct Polygon {
    public var vertices: [CGPoint]

    public init(_ vertices: [CGPoint]) {
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
