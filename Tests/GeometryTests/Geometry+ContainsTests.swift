import CoreGraphics
import Geometry
import Testing

@Test func testLineSegmentContainsPointWithinRadius() {
    let seg = LineSegment(start: CGPoint.zero, end: CGPoint(x: 2, y: 0))
    let pt = CGPoint(x: 1, y: 0.5)
    #expect(seg.contains(pt, within: 0.5))
    #expect(!seg.contains(pt, within: 0.4))
    // Endpoint
    #expect(seg.contains(CGPoint.zero, within: 0.0))
}
