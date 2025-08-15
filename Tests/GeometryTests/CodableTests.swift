import CoreGraphics
import Foundation
import Geometry
import Testing

@Suite("Codable Tests")
struct CodableTests {
    // MARK: - Circle Codable

    @Test("Circle encoding and decoding")
    func testCircleCodable() throws {
        let circle = Circle(center: CGPoint(x: 5, y: 10), radius: 3.5)

        let encoder = JSONEncoder()
        let data = try encoder.encode(circle)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Circle.self, from: data)

        #expect(decoded.center == circle.center)
        #expect(decoded.radius == circle.radius)
    }

    // MARK: - Line Codable

    @Test("Line encoding and decoding")
    func testLineCodable() throws {
        let line = Line(point: CGPoint(x: 1, y: 2), direction: CGVector(dx: 3, dy: 4))

        let encoder = JSONEncoder()
        let data = try encoder.encode(line)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Line.self, from: data)

        #expect(decoded.point == line.point)
        #expect(decoded.direction == line.direction)
    }

    // MARK: - LineSegment Codable

    @Test("LineSegment encoding and decoding")
    func testLineSegmentCodable() throws {
        let segment = LineSegment(start: CGPoint.zero, end: CGPoint(x: 10, y: 10))

        let encoder = JSONEncoder()
        let data = try encoder.encode(segment)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(LineSegment.self, from: data)

        #expect(decoded.start == segment.start)
        #expect(decoded.end == segment.end)
    }

    // MARK: - Polygon Codable

    @Test("Polygon encoding and decoding")
    func testPolygonCodable() throws {
        let polygon = Polygon([
            CGPoint.zero,
            CGPoint(x: 10, y: 0),
            CGPoint(x: 10, y: 10),
            CGPoint(x: 0, y: 10)
        ])

        let encoder = JSONEncoder()
        let data = try encoder.encode(polygon)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Polygon.self, from: data)

        #expect(decoded.vertices == polygon.vertices)
    }

    // MARK: - Polyline Codable

    @Test("Polyline encoding and decoding")
    func testPolylineCodable() throws {
        let polyline = Polyline(vertices: [
            CGPoint.zero,
            CGPoint(x: 5, y: 5),
            CGPoint(x: 10, y: 0)
        ])

        let encoder = JSONEncoder()
        let data = try encoder.encode(polyline)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Polyline.self, from: data)

        #expect(decoded.vertices == polyline.vertices)
    }

    @Test("Polyline with single vertex")
    func testPolylineSingleVertexCodable() throws {
        let polyline = Polyline(vertices: [CGPoint(x: 5, y: 5)])

        let encoder = JSONEncoder()
        let data = try encoder.encode(polyline)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Polyline.self, from: data)

        #expect(decoded.vertices == polyline.vertices)
    }

    // MARK: - Ray Codable

    @Test("Ray encoding and decoding")
    func testRayCodable() throws {
        let ray = Ray(origin: CGPoint.zero, direction: CGVector(dx: 1, dy: 1))

        let encoder = JSONEncoder()
        let data = try encoder.encode(ray)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Ray.self, from: data)

        #expect(decoded.origin == ray.origin)
        #expect(decoded.direction == ray.direction)
    }

    @Test("Ray with normalized direction")
    func testRayNormalizedCodable() throws {
        let ray = Ray(origin: CGPoint(x: 5, y: 5), direction: CGVector(dx: 3, dy: 4))

        let encoder = JSONEncoder()
        let data = try encoder.encode(ray)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Ray.self, from: data)

        // Ray normalizes direction in init
        #expect(decoded.origin == ray.origin)
        #expect(decoded.direction == ray.direction)
    }
}
