import CoreGraphics
import Geometry
import Testing

@Test func testLineSegmentInitAndProperties() {
    let startPoint = CGPoint.zero
    let endPoint = CGPoint(x: 4, y: 0)
    let segment = LineSegment(start: startPoint, end: endPoint)
    #expect(segment.start == startPoint)
    #expect(segment.end == endPoint)
    #expect(segment.points == [startPoint, endPoint])
    #expect(segment.mid == CGPoint(x: 2, y: 0))
    #expect(segment.length == 4)
    #expect(segment.angle.radians == 0)
    #expect(segment.direction == CGVector(dx: 1, dy: 0))
    #expect(segment.normal == CGVector(dx: 0, dy: 1))
}

@Test func testLineSegmentContainsPoint() {
    let segment = LineSegment(start: .zero, end: CGPoint(x: 4, y: 0))
    #expect(segment.contains(CGPoint(x: 2, y: 0)))
    #expect(!segment.contains(CGPoint(x: 5, y: 0)))
    #expect(segment.contains(.zero))
    #expect(segment.contains(CGPoint(x: 4, y: 0)))
    #expect(!segment.contains(CGPoint(x: 2, y: 1)))
    #expect(segment.contains(CGPoint(x: 2, y: 0), interior: true))
    #expect(!segment.contains(.zero, interior: true))
}

@Test func testLineSegmentContainsSegment() {
    let segment = LineSegment(start: .zero, end: CGPoint(x: 4, y: 0))
    let subSegment = LineSegment(start: CGPoint(x: 1, y: 0), end: CGPoint(x: 3, y: 0))
    #expect(segment.contains(subSegment))
    #expect(!subSegment.contains(segment))
}

@Test func testLineSegmentInitCenterWidthDirection() {
    let centerPoint = CGPoint.zero
    let segmentWidth: CGFloat = 4
    let directionVector = CGVector(dx: 1, dy: 0)
    let segment = LineSegment(center: centerPoint, width: segmentWidth, direction: directionVector)
    #expect(segment.length == 4)
    #expect(segment.mid.isApproximatelyEqual(to: centerPoint, epsilon: 0.0001))
}
