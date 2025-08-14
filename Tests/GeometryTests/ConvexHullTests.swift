import CoreGraphics
import Geometry
import Testing

@Test func testConvexHullSquare() {
    let points = [CGPoint.zero, CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1), CGPoint(x: 0, y: 1)]
    let hull = convexHull(points)
    #expect(hull.count == 4)
    #expect(hull.contains(CGPoint.zero))
    #expect(hull.contains(CGPoint(x: 1, y: 0)))
    #expect(hull.contains(CGPoint(x: 1, y: 1)))
    #expect(hull.contains(CGPoint(x: 0, y: 1)))
}

@Test func testConvexHullTriangle() {
    let points = [CGPoint.zero, CGPoint(x: 2, y: 0), CGPoint(x: 1, y: 1)]
    let hull = convexHull(points)
    #expect(hull.count == 3)
    #expect(hull.contains(CGPoint.zero))
    #expect(hull.contains(CGPoint(x: 2, y: 0)))
    #expect(hull.contains(CGPoint(x: 1, y: 1)))
}

@Test func testConvexHullCollinear() {
    let points = [CGPoint.zero, CGPoint(x: 1, y: 0), CGPoint(x: 2, y: 0)]
    let hull = convexHull(points)
    #expect(hull.count == 2)
    #expect(hull.contains(CGPoint.zero))
    #expect(hull.contains(CGPoint(x: 2, y: 0)))
}

@Test func testConvexHullDuplicates() {
    let points = [
        CGPoint.zero, CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1),
        CGPoint(x: 0, y: 1), CGPoint.zero, CGPoint(x: 1, y: 0)
    ]
    let hull = convexHull(points)
    #expect(hull.count == 4)
}

@Test func testConvexHullUnordered() {
    let points = [CGPoint(x: 1, y: 1), CGPoint.zero, CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 0)]
    let hull = convexHull(points)
    #expect(hull.count == 4)
    #expect(hull.contains(CGPoint.zero))
    #expect(hull.contains(CGPoint(x: 1, y: 0)))
    #expect(hull.contains(CGPoint(x: 1, y: 1)))
    #expect(hull.contains(CGPoint(x: 0, y: 1)))
}

@Test func testUntwistConvexPolygonSquare() {
    let points = [
        CGPoint.zero,
        CGPoint(x: 1, y: 0),
        CGPoint(x: 1, y: 1),
        CGPoint(x: 0, y: 1)
    ]
    let untwisted = untwistConvexPolygon(points)
    #expect(untwisted == [
        CGPoint.zero,
        CGPoint(x: 1, y: 0),
        CGPoint(x: 1, y: 1),
        CGPoint(x: 0, y: 1)
    ])
}

@Test func testUntwistConvexPolygonTriangle() {
    let points = [
        CGPoint.zero,
        CGPoint(x: 2, y: 0),
        CGPoint(x: 1, y: 1)
    ]
    let untwisted = untwistConvexPolygon(points)
    #expect(untwisted == [
        CGPoint.zero,
        CGPoint(x: 2, y: 0),
        CGPoint(x: 1, y: 1)
    ])
}

@Test func testUntwistConvexPolygonUnordered() {
    let points = [
        CGPoint(x: 1, y: 1),
        CGPoint.zero,
        CGPoint(x: 0, y: 1),
        CGPoint(x: 1, y: 0)
    ]
    let untwisted = untwistConvexPolygon(points)
    #expect(untwisted == [
        CGPoint.zero,
        CGPoint(x: 1, y: 0),
        CGPoint(x: 1, y: 1),
        CGPoint(x: 0, y: 1)
    ])
}
