import CoreGraphics
import Geometry
import Testing

@Test func testPolygonInitAndProperties() {
    let points = [.zero, CGPoint(x: 1, y: 0), CGPoint(x: 0, y: 1)]
    let polygon = Polygon(points)
    #expect(polygon.vertices == points)
    #expect(polygon.vertices.count == 3)
}

@Test func testPolygonIsSimple() {
    // Simple triangle
    let triangle = Polygon([.zero, CGPoint(x: 1, y: 0), CGPoint(x: 0, y: 1)])
    #expect(triangle.isSimple())
    // Self-intersecting (bowtie)
    let bowtie = Polygon([
        .zero, CGPoint(x: 1, y: 1), CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 0)
    ])
    #expect(!bowtie.isSimple())
}

@Test func testPolygonIsConvex() {
    let square = Polygon([
        .zero, CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1), CGPoint(x: 0, y: 1)
    ])
    #expect(square.isConvex)
    let concave = Polygon([
        .zero, CGPoint(x: 2, y: 0), CGPoint(x: 1, y: 1), CGPoint(x: 2, y: 2), CGPoint(x: 0, y: 2)
    ])
    #expect(!concave.isConvex)
}

@Test func testPolygonSimpleArea() {
    let square = Polygon([
        .zero, CGPoint(x: 2, y: 0), CGPoint(x: 2, y: 2), CGPoint(x: 0, y: 2)
    ])
    #expect(abs(square.signedArea) == 4)
    let triangle = Polygon([
        .zero, CGPoint(x: 4, y: 0), CGPoint(x: 0, y: 3)
    ])
    #expect(abs(triangle.signedArea) == 6)
}
