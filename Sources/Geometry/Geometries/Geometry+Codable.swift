import CoreGraphics
import Foundation

// #if !canImport(CoreGraphics)
// extension CGPoint: Codable {
//     public init(from decoder: Decoder) throws {
//         var container = try decoder.unkeyedContainer()
//         self.x = try container.decode(Double.self)
//         self.y = try container.decode(Double.self)
//     }

//     public func encode(to encoder: any Encoder) throws {
//         var container = encoder.unkeyedContainer()
//         try container.encode(x)
//         try container.encode(y)

//     }
// }

// extension CGSize: Codable {
// }
// #else
// import CoreGraphics
// #endif

// MARK: -

/// Encodes as [[center.x, center.y], radius]
extension Circle: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let center = try container.decode(CGPoint.self)
        let radius = try container.decode(Double.self)
        self.init(center: center, radius: radius)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(center)
        try container.encode(radius)
    }
}

// MARK: -

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

// MARK: -

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

// MARK: -

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

// MARK: -

/// Encodes as [[x, y], ...]
extension Polyline: Codable {
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

// MARK: -

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
