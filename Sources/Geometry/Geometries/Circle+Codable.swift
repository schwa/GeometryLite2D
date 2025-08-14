import CoreGraphics
import Foundation

/// Encodes as [[center.x, center.y], radius]
extension Circle: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let center = try container.decode(CGPoint.self)
        let radius = try container.decode(Double.self)
        self.init(center: center, radius: radius)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(center)
        try container.encode(radius)
    }
}