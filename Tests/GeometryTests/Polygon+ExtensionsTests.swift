import CoreGraphics
import Geometry
import Testing

@Test
func testWindingCounterClockwise() {
    let poly = Polygon([
        CGPoint.zero,
        CGPoint(x: 1, y: 0),
        CGPoint(x: 1, y: 1),
        CGPoint(x: 0, y: 1)
    ])
    #expect(poly.winding == .counterClockwise)
}

@Test
func testWindingClockwise() {
    let poly = Polygon([
        CGPoint.zero,
        CGPoint(x: 0, y: 1),
        CGPoint(x: 1, y: 1),
        CGPoint(x: 1, y: 0)
    ])
    #expect(poly.winding == .clockwise)
}

@Test(.disabled())
func testMergePolygonsRemovesSharedEdge() {
    let poly1 = Polygon([
        CGPoint.zero,
        CGPoint(x: 1, y: 0),
        CGPoint(x: 1, y: 1),
        CGPoint(x: 0, y: 1)
    ])
    let poly2 = Polygon([
        CGPoint(x: 1, y: 0),
        CGPoint(x: 2, y: 0),
        CGPoint(x: 2, y: 1),
        CGPoint(x: 1, y: 1)
    ])
    let merged = Polygon.merge(polygons: [poly1, poly2])
    #expect(merged.count == 1)
    #expect(merged[0].vertices.count == 6)
    // Should contain all unique points
    let allPoints = Set(merged[0].vertices)
    let expectedPoints: Set<CGPoint> = [CGPoint.zero, CGPoint(x: 2, y: 0), CGPoint(x: 2, y: 1), CGPoint(x: 0, y: 1)]
    #expect(allPoints.isSuperset(of: expectedPoints))
}

@Test
func testMergePolygonsNoSharedEdge() {
    let poly1 = Polygon([
        CGPoint.zero,
        CGPoint(x: 1, y: 0),
        CGPoint(x: 1, y: 1),
        CGPoint(x: 0, y: 1)
    ])
    let poly2 = Polygon([
        CGPoint(x: 2, y: 0),
        CGPoint(x: 3, y: 0),
        CGPoint(x: 3, y: 1),
        CGPoint(x: 2, y: 1)
    ])
    let merged = Polygon.merge(polygons: [poly1, poly2])
    #expect(merged.count == 2)
}

@Test
func testPolygonInitEdges() {
    let edges = [
        LineSegment(CGPoint.zero, CGPoint(x: 1, y: 0)),
        LineSegment(CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1)),
        LineSegment(CGPoint(x: 1, y: 1), CGPoint.zero)
    ]
    let poly = Polygon(edges: edges)
    #expect(poly != nil)
    #expect(poly!.vertices.count == 3)
}

@Test
func testPolygonInitEdgesFailsOnOpen() {
    let edges = [
        LineSegment(CGPoint.zero, CGPoint(x: 1, y: 0)),
        LineSegment(CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1))
    ]
    let poly = Polygon(edges: edges)
    #expect(poly == nil)
}

@Test
func testSimplifiedRemovesColinear() {
    let poly = Polygon([
        CGPoint.zero,
        CGPoint(x: 1, y: 0),
        CGPoint(x: 2, y: 0), // colinear
        CGPoint(x: 2, y: 1),
        CGPoint(x: 0, y: 1)
    ])
    let simplified = poly.simplified()
    #expect(simplified.vertices.count == 4)
    #expect(!simplified.vertices.contains(CGPoint(x: 1, y: 0)))
}

@Test
func testSimplifiedRemovesClosePoints() {
    let poly = Polygon([
        CGPoint.zero,
        CGPoint(x: 1e-6, y: 0), // very close
        CGPoint(x: 1, y: 0),
        CGPoint(x: 1, y: 1),
        CGPoint(x: 0, y: 1)
    ])
    let simplified = poly.simplified()
    #expect(simplified.vertices.count == 4)
    let expectedVertices = [CGPoint.zero, CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1), CGPoint(x: 0, y: 1)]
    #expect(simplified.vertices == expectedVertices)
}
