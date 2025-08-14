import CoreGraphics
import Foundation

/// Encodes as [[start.x, start.y], [end.x, end.y]]
extension LineSegment: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.start = try container.decode(CGPoint.self)
        self.end = try container.decode(CGPoint.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(start)
        try container.encode(end)
    }
}