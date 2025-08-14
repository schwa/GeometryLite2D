import CoreGraphics
import Geometry
import Testing

@Test func testIntersectionOfLines() {
    let p1 = CGPoint.zero
    let d1 = CGPoint(x: 1, y: 1)
    let p2 = CGPoint(x: 0, y: 1)
    let d2 = CGPoint(x: 1, y: -1)
    let intersection = intersectionOfLines(p1, d1, p2, d2)
    #expect(intersection?.x == 0.5 && intersection?.y == 0.5)

    // Parallel lines
    let p3 = CGPoint.zero
    let d3 = CGPoint(x: 1, y: 0)
    let p4 = CGPoint(x: 0, y: 1)
    let d4 = CGPoint(x: 1, y: 0)
    #expect(intersectionOfLines(p3, d3, p4, d4) == nil)
}

@Test func testLineIntersection() {
    let l1 = Line(point: CGPoint.zero, direction: CGVector(dx: 1, dy: 1))
    let l2 = Line(point: CGPoint(x: 0, y: 1), direction: CGVector(dx: 1, dy: -1))
    let intersection = l1.intersection(with: l2)
    #expect(intersection?.x == 0.5 && intersection?.y == 0.5)

    // Parallel
    let l3 = Line(point: CGPoint.zero, direction: CGVector(dx: 1, dy: 0))
    let l4 = Line(point: CGPoint(x: 0, y: 1), direction: CGVector(dx: 1, dy: 0))
    #expect(l3.intersection(with: l4) == nil)
}

@Test func testLineSegmentIntersects() {
    let seg1 = LineSegment(start: CGPoint.zero, end: CGPoint(x: 1, y: 1))
    let seg2 = LineSegment(start: CGPoint(x: 0, y: 1), end: CGPoint(x: 1, y: 0))
    #expect(seg1.intersects(seg2))

    // Collinear and overlapping
    let seg3 = LineSegment(start: CGPoint.zero, end: CGPoint(x: 2, y: 0))
    let seg4 = LineSegment(start: CGPoint(x: 1, y: 0), end: CGPoint(x: 3, y: 0))
    #expect(seg3.intersects(seg4))

    // Collinear but not overlapping
    let seg5 = LineSegment(start: CGPoint.zero, end: CGPoint(x: 1, y: 0))
    let seg6 = LineSegment(start: CGPoint(x: 2, y: 0), end: CGPoint(x: 3, y: 0))
    #expect(!seg5.intersects(seg6))

    // Not intersecting
    let seg7 = LineSegment(start: CGPoint.zero, end: CGPoint(x: 1, y: 0))
    let seg8 = LineSegment(start: CGPoint(x: 0, y: 1), end: CGPoint(x: 1, y: 1))
    #expect(!seg7.intersects(seg8))
}

@Test func testLineSegmentRayIntersection() {
    let seg = LineSegment(start: CGPoint.zero, end: CGPoint(x: 1, y: 0))
    let ray = Ray(origin: CGPoint(x: 0.5, y: -1), direction: CGVector(dx: 0, dy: 1))
    let intersection = seg.intersection(ray)
    #expect(intersection?.x == 0.5 && intersection?.y == 0)

    // Parallel
    let ray2 = Ray(origin: CGPoint(x: 0, y: 1), direction: CGVector(dx: 1, dy: 0))
    #expect(seg.intersection(ray2) == nil)
}

@Test func testRayIntersection() {
    let ray1 = Ray(origin: CGPoint.zero, direction: CGVector(dx: 1, dy: 1))
    let ray2 = Ray(origin: CGPoint(x: 0, y: 1), direction: CGVector(dx: 1, dy: -1))
    let intersection = ray1.intersection(with: ray2)
    #expect(intersection?.x == 0.5 && intersection?.y == 0.5)

    // Parallel
    let ray3 = Ray(origin: CGPoint.zero, direction: CGVector(dx: 1, dy: 0))
    let ray4 = Ray(origin: CGPoint(x: 0, y: 1), direction: CGVector(dx: 1, dy: 0))
    #expect(ray3.intersection(with: ray4) == nil)
}

@Test func testCGRectIntersectsLineSegment() {
    let rect = CGRect(x: 0, y: 0, width: 2, height: 2)
    let seg1 = LineSegment(start: CGPoint(x: -1, y: 1), end: CGPoint(x: 3, y: 1))
    #expect(rect.intersects(seg1))
    let seg2 = LineSegment(start: CGPoint(x: -1, y: -1), end: CGPoint(x: -1, y: 3))
    #expect(!rect.intersects(seg2))
}
