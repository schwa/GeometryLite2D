import CoreGraphics
import Geometry
import Testing

@Test func testPolylineInitAndProperties() {
    let points = [CGPoint.zero, CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1)]
    let polyline = Polyline(vertices: points)
    #expect(polyline.vertices == points)
    #expect(polyline.vertices.count == 3)
}

@Test func testPolylineIsClosed() {
    let open = Polyline(vertices: [CGPoint.zero, CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1)])
    #expect(!open.isClosed())
    let closed = Polyline(vertices: [CGPoint.zero, CGPoint(x: 1, y: 0), CGPoint.zero])
    #expect(closed.isClosed())
}

@Test func testPolylineIsApproximatelyClosed() {
    let closed = Polyline(vertices: [CGPoint.zero, CGPoint(x: 1, y: 0), CGPoint(x: 0.001, y: 0.001)])
    #expect(closed.isClosed(absoluteTolerance: 0.01))
    #expect(!closed.isClosed(absoluteTolerance: 0.0001))
}

@Test func testPolylineLength() {
    let polyline = Polyline(vertices: [CGPoint.zero, CGPoint(x: 3, y: 0), CGPoint(x: 3, y: 4)])
    let length = polyline.segments.reduce(0) { $0 + $1.length }
    #expect(length == 7)
}

@Test func testPolylineSegment() {
    let polyline = Polyline(vertices: [CGPoint.zero, CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1)])
    let seg = polyline.segments[1]
    #expect(seg.start == CGPoint(x: 1, y: 0))
    #expect(seg.end == CGPoint(x: 1, y: 1))
}

@Test func testPolylineReversed() {
    let polyline = Polyline(vertices: [CGPoint.zero, CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1)])
    let rev = Polyline(vertices: polyline.vertices.reversed())
    #expect(rev.vertices == Array(polyline.vertices.reversed()))
}

@Test func testPolylineSubscript() {
    let polyline = Polyline(vertices: [CGPoint.zero, CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1)])
    #expect(polyline.vertices[0] == CGPoint.zero)
    #expect(polyline.vertices[2] == CGPoint(x: 1, y: 1))
}

@Test func testPolylineEmpty() {
    let polyline = Polyline(vertices: [])
    #expect(polyline.vertices.isEmpty)
    #expect(polyline.segments.isEmpty)
}

@Test func testPolylineSinglePoint() {
    let polyline = Polyline(vertices: [CGPoint.zero])
    #expect(polyline.vertices.count == 1)
    #expect(polyline.segments.isEmpty)
}

@Test func testPolylineDuplicatePoints() {
    let points = [CGPoint.zero, CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1)]
    let polyline = Polyline(vertices: points)
    #expect(polyline.vertices == points)
    #expect(polyline.segments.count == 3)
}

@Test func testPolylineCollinearPoints() {
    let points = [CGPoint.zero, CGPoint(x: 1, y: 0), CGPoint(x: 2, y: 0)]
    let polyline = Polyline(vertices: points)
    #expect(polyline.vertices == points)
    let length = polyline.segments.reduce(0) { $0 + $1.length }
    #expect(length == 2)
}

@Test func testPolylineContainsLoops() {
    let looped = Polyline(vertices: [CGPoint.zero, CGPoint(x: 1, y: 0), CGPoint(x: 0, y: 1), CGPoint.zero])
    #expect(looped.containsLoops())
    let noLoop = Polyline(vertices: [CGPoint.zero, CGPoint(x: 1, y: 0), CGPoint(x: 0, y: 1)])
    #expect(!noLoop.containsLoops())
}

@Test func testPolylinesFromLineSegments() {
    let segments = [
        LineSegment(start: CGPoint.zero, end: CGPoint(x: 1, y: 0)),
        LineSegment(start: CGPoint(x: 1, y: 0), end: CGPoint(x: 1, y: 1)),
        LineSegment(start: CGPoint(x: 2, y: 2), end: CGPoint(x: 3, y: 3))
    ]
    let polylines = Polyline.polylines(from: segments)
    #expect(polylines.count == 2)
    #expect(polylines[0].vertices == [CGPoint.zero, CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1)])
    #expect(polylines[1].vertices == [CGPoint(x: 2, y: 2), CGPoint(x: 3, y: 3)])
}
