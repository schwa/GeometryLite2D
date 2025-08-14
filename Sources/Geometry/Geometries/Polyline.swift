#if canImport(CoreGraphics)
import CoreGraphics
#else
import Foundation
#endif

public struct Polyline {
    public var vertices: [CGPoint]

    public init(vertices: [CGPoint]) {
        self.vertices = vertices
    }
}

extension Polyline: Equatable {
}

extension Polyline: Sendable {
}