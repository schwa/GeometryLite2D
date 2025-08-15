import CoreGraphics
import Foundation

/// Encodes as [[x, y], ...]
extension Polygon: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let points = try container.decode([[CGFloat]].self)
        self.vertices = points.map { CGPoint(x: $0[0], y: $0[1]) }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(vertices.map { [$0.x, $0.y] })
    }
}
