import CoreGraphics
import Foundation

/// Encodes as [x, y, dx, dy]
extension Line: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let x = try container.decode(Double.self)
        let y = try container.decode(Double.self)
        let dx = try container.decode(Double.self)
        let dy = try container.decode(Double.self)
        self.point = CGPoint(x: x, y: y)
        self.direction = CGVector(dx: dx, dy: dy)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(point.x)
        try container.encode(point.y)
        try container.encode(direction.dx)
        try container.encode(direction.dy)
    }
}