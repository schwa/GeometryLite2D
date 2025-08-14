import CoreGraphics
import Geometry
import Testing

@Test func testLineInitAndProperties() {
    let p1 = CGPoint.zero
    let p2 = CGPoint(x: 4, y: 0)
    let line = Line(p1: p1, p2: p2)
    #expect(line.point == p1)
    #expect(line.direction == CGVector(dx: 4, dy: 0))
}

@Test func testLineContains() {
    let line = Line(p1: .zero, p2: CGPoint(x: 4, y: 0))
    #expect(line.contains(CGPoint(x: 2, y: 0)))
    #expect(line.contains(CGPoint(x: -2, y: 0)))
    #expect(!line.contains(CGPoint(x: 0, y: 1)))
}

@Test func testLinePerpendicularThrough() {
    let line = Line(p1: .zero, p2: CGPoint(x: 4, y: 0))
    let perp = line.perpendicularThrough(CGPoint(x: 2, y: 2))
    #expect(perp.point == CGPoint(x: 2, y: 2))
    #expect(perp.direction == CGVector(dx: 0, dy: 4) || perp.direction == CGVector(dx: 0, dy: -4))
}

@Test func testLineParallelTo() {
    let line = Line(p1: .zero, p2: CGPoint(x: 4, y: 0))
    let offsetLine = line.parallelTo(2)
    #expect(offsetLine.point.isApproximatelyEqual(to: CGPoint(x: 0, y: 2), absoluteTolerance: 1e-6))
    #expect(offsetLine.direction == line.direction)
}
