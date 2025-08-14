import CoreGraphics
import Geometry
import Testing

@Test func testRayInitAndProperties() {
    let origin = CGPoint(x: 1, y: 2)
    let dir = CGVector(dx: 3, dy: 4)
    let ray = Ray(origin: origin, direction: dir)
    #expect(ray.origin == origin)
    #expect(ray.direction == dir)
}

@Test func testRayInitFromToward() {
    let p1 = CGPoint.zero
    let p2 = CGPoint(x: 2, y: 2)
    let ray = Ray(from: p1, toward: p2)
    #expect(ray.origin == p1)
    #expect(ray.direction == CGVector(dx: 2, dy: 2))
}

@Test func testRayPointAt() {
    let ray = Ray(origin: CGPoint.zero, direction: CGVector(dx: 1, dy: 0))
    #expect(ray.point(at: 0) == CGPoint.zero)
    #expect(ray.point(at: 2) == CGPoint(x: 2, y: 0))
}

@Test func testRayContains() {
    let ray = Ray(origin: CGPoint.zero, direction: CGVector(dx: 1, dy: 1))
    #expect(ray.contains(CGPoint.zero))
    #expect(ray.contains(CGPoint(x: 2, y: 2)))
    #expect(!ray.contains(CGPoint(x: -1, y: -1)))
    #expect(!ray.contains(CGPoint(x: 1, y: 2)))
}

@Test func testRayProjectedPoint() {
    let ray = Ray(origin: CGPoint.zero, direction: CGVector(dx: 1, dy: 0))
    let p = CGPoint(x: 3, y: 4)
    let proj = ray.projectedPoint(from: p)
    #expect(proj.isApproximatelyEqual(to: CGPoint(x: 3, y: 0)))
    let before = CGPoint(x: -2, y: 5)
    let proj2 = ray.projectedPoint(from: before)
    #expect(proj2.isApproximatelyEqual(to: CGPoint.zero))
}

@Test func testRayParallelTo() {
    let ray = Ray(origin: CGPoint.zero, direction: CGVector(dx: 2, dy: 0))
    let offsetRay = ray.parallelTo(3)
    #expect(offsetRay.origin.isApproximatelyEqual(to: CGPoint(x: 0, y: 3)))
    #expect(offsetRay.direction == ray.direction)
}
// Note: Precondition failure for zero direction cannot be caught in Swift, so we do not test it here.
