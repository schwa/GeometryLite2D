import CoreGraphics
import Foundation

/// Encodes as [x, y, dx, dy]
extension Ray: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let x = try container.decode(Double.self)
        let y = try container.decode(Double.self)
        let dx = try container.decode(Double.self)
        let dy = try container.decode(Double.self)
        self.origin = CGPoint(x: x, y: y)
        self.direction = CGVector(dx: dx, dy: dy)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(origin.x)
        try container.encode(origin.y)
        try container.encode(direction.dx)
        try container.encode(direction.dy)
    }
}
