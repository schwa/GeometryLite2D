import CoreGraphics
import Geometry
import Testing

@Suite("LineSegment Approximate Equality Tests")
struct LineSegmentApproximateEqualityTests {
    @Test("Exact equality")
    func testExactEquality() {
        let s1 = LineSegment(start: CGPoint.zero, end: CGPoint(x: 10, y: 10))
        let s2 = LineSegment(start: CGPoint.zero, end: CGPoint(x: 10, y: 10))

        #expect(s1.isApproximatelyEqual(to: s2, absoluteTolerance: 0))
        #expect(s1.isApproximatelyEqual(to: s2, absoluteTolerance: 1e-10))
    }

    @Test("Within tolerance")
    func testWithinTolerance() {
        let s1 = LineSegment(start: CGPoint.zero, end: CGPoint(x: 10, y: 10))
        let s2 = LineSegment(start: CGPoint(x: 0.00001, y: 0.00001), end: CGPoint(x: 10.00001, y: 10.00001))

        #expect(s1.isApproximatelyEqual(to: s2, absoluteTolerance: 1e-4))
        #expect(!s1.isApproximatelyEqual(to: s2, absoluteTolerance: 1e-6))
    }

    @Test("Different endpoints")
    func testDifferentEndpoints() {
        let s1 = LineSegment(start: CGPoint.zero, end: CGPoint(x: 10, y: 10))
        let s2 = LineSegment(start: CGPoint.zero, end: CGPoint(x: 10, y: 11))

        #expect(!s1.isApproximatelyEqual(to: s2, absoluteTolerance: 0.5))
        #expect(s1.isApproximatelyEqual(to: s2, absoluteTolerance: 1.5))
    }

    @Test("Reversed segments are not equal")
    func testReversedSegments() {
        let s1 = LineSegment(start: CGPoint.zero, end: CGPoint(x: 10, y: 10))
        let s2 = LineSegment(start: CGPoint(x: 10, y: 10), end: CGPoint.zero)

        // Reversed segments are not considered equal
        #expect(!s1.isApproximatelyEqual(to: s2, absoluteTolerance: 1e-10))
    }

    @Test("With relative tolerance")
    func testRelativeTolerance() {
        let s1 = LineSegment(start: CGPoint(x: 1_000, y: 1_000), end: CGPoint(x: 2_000, y: 2_000))
        let s2 = LineSegment(start: CGPoint(x: 1_001, y: 1_001), end: CGPoint(x: 2_001, y: 2_001))

        // With absolute tolerance only
        #expect(!s1.isApproximatelyEqual(to: s2, absoluteTolerance: 0.5, relativeTolerance: 0))

        // With relative tolerance
        #expect(s1.isApproximatelyEqual(to: s2, absoluteTolerance: 0, relativeTolerance: 0.001))
    }
}
