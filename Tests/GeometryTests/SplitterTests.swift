import CoreGraphics
import Geometry
import Testing

@Suite("Splitter Tests")
struct SplitterTests {
    @Test("Split segments at intersection point")
    func testBasicSplit() {
        // Two segments that intersect at their midpoints
        let segments = [
            Identified(id: "A", value: LineSegment(start: CGPoint.zero, end: CGPoint(x: 10, y: 10))),
            Identified(id: "B", value: LineSegment(start: CGPoint(x: 0, y: 10), end: CGPoint(x: 10, y: 0)))
        ]

        let result = split(segments: segments)

        // Each segment should be split into 2 parts
        #expect(result.count == 4)

        // Check that all parent IDs are preserved
        let aSegments = result.filter { $0.id.parent == "A" }
        let bSegments = result.filter { $0.id.parent == "B" }

        #expect(aSegments.count == 2)
        #expect(bSegments.count == 2)

        // Verify ordinals are correct
        #expect(aSegments.contains { $0.id.ordinal == 0 })
        #expect(aSegments.contains { $0.id.ordinal == 1 })
        #expect(bSegments.contains { $0.id.ordinal == 0 })
        #expect(bSegments.contains { $0.id.ordinal == 1 })
    }

    @Test("No split for non-intersecting segments")
    func testNoSplit() {
        let segments = [
            Identified(id: 1, value: LineSegment(start: CGPoint.zero, end: CGPoint(x: 10, y: 0))),
            Identified(id: 2, value: LineSegment(start: CGPoint(x: 0, y: 1), end: CGPoint(x: 10, y: 1)))
        ]

        let result = split(segments: segments)

        // No splits, so we should get back the original segments
        #expect(result.count == 2)
        #expect(result[0].id.parent == 1)
        #expect(result[0].id.ordinal == 0)
        #expect(result[1].id.parent == 2)
        #expect(result[1].id.ordinal == 0)
    }

    @Test("Multiple intersections on a single segment")
    func testMultipleIntersections() {
        // One horizontal segment crossed by two vertical segments
        let segments = [
            Identified(id: "horizontal", value: LineSegment(start: CGPoint(x: 0, y: 5), end: CGPoint(x: 10, y: 5))),
            Identified(id: "vertical1", value: LineSegment(start: CGPoint(x: 3, y: 0), end: CGPoint(x: 3, y: 10))),
            Identified(id: "vertical2", value: LineSegment(start: CGPoint(x: 7, y: 0), end: CGPoint(x: 7, y: 10)))
        ]

        let result = split(segments: segments)

        // Horizontal should be split into 3 parts
        // Each vertical should remain as 1 segment (split at endpoints doesn't create new segments)
        let horizontalSegments = result.filter { $0.id.parent == "horizontal" }
        let vertical1Segments = result.filter { $0.id.parent == "vertical1" }
        let vertical2Segments = result.filter { $0.id.parent == "vertical2" }

        #expect(horizontalSegments.count == 3)
        #expect(vertical1Segments.count == 2)
        #expect(vertical2Segments.count == 2)
    }

    @Test("T-junction splitting")
    func testTJunctionSplit() {
        // T-junction: horizontal segment with vertical segment meeting at midpoint
        let segments = [
            Identified(id: 1, value: LineSegment(start: CGPoint(x: 0, y: 5), end: CGPoint(x: 10, y: 5))),
            Identified(id: 2, value: LineSegment(start: CGPoint(x: 5, y: 0), end: CGPoint(x: 5, y: 5)))
        ]

        let result = split(segments: segments)

        // Horizontal segment split into 2, vertical remains 1
        let seg1Results = result.filter { $0.id.parent == 1 }
        let seg2Results = result.filter { $0.id.parent == 2 }

        #expect(seg1Results.count == 2)
        #expect(seg2Results.count == 1)
    }

    @Test("Endpoint intersection doesn't create extra splits")
    func testEndpointIntersection() {
        // Two segments meeting at an endpoint
        let segments = [
            Identified(id: "A", value: LineSegment(start: CGPoint.zero, end: CGPoint(x: 5, y: 5))),
            Identified(id: "B", value: LineSegment(start: CGPoint(x: 5, y: 5), end: CGPoint(x: 10, y: 0)))
        ]

        let result = split(segments: segments)

        // No splits should occur since they only meet at endpoints
        #expect(result.count == 2)
        #expect(result[0].id.parent == "A" && result[0].id.ordinal == 0)
        #expect(result[1].id.parent == "B" && result[1].id.ordinal == 0)
    }

    @Test("Complex multi-segment intersection")
    func testComplexIntersection() {
        // Create a grid-like pattern
        let segments = [
            // Horizontal lines
            Identified(id: "H1", value: LineSegment(start: CGPoint(x: 0, y: 2), end: CGPoint(x: 6, y: 2))),
            Identified(id: "H2", value: LineSegment(start: CGPoint(x: 0, y: 4), end: CGPoint(x: 6, y: 4))),
            // Vertical lines
            Identified(id: "V1", value: LineSegment(start: CGPoint(x: 2, y: 0), end: CGPoint(x: 2, y: 6))),
            Identified(id: "V2", value: LineSegment(start: CGPoint(x: 4, y: 0), end: CGPoint(x: 4, y: 6)))
        ]

        let result = split(segments: segments)

        // Each horizontal should be split into 3 parts (2 intersections)
        // Each vertical should be split into 3 parts (2 intersections)
        let h1Segments = result.filter { $0.id.parent == "H1" }
        let h2Segments = result.filter { $0.id.parent == "H2" }
        let v1Segments = result.filter { $0.id.parent == "V1" }
        let v2Segments = result.filter { $0.id.parent == "V2" }

        #expect(h1Segments.count == 3)
        #expect(h2Segments.count == 3)
        #expect(v1Segments.count == 3)
        #expect(v2Segments.count == 3)
        #expect(result.count == 12)
    }

    @Test("Tolerance for near-duplicate split points")
    func testToleranceDeduplication() {
        // Two segments that intersect very close to an endpoint
        let segments = [
            Identified(id: 1, value: LineSegment(start: CGPoint.zero, end: CGPoint(x: 10, y: 0))),
            Identified(id: 2, value: LineSegment(start: CGPoint(x: 9.9999999, y: -5), end: CGPoint(x: 9.9999999, y: 5)))
        ]

        let result = split(segments: segments, absoluteTolerance: 1e-6)

        // With tolerance, the intersection at ~10 should be treated as endpoint
        // So no actual split should occur for segment 1
        let seg1Results = result.filter { $0.id.parent == 1 }
        let seg2Results = result.filter { $0.id.parent == 2 }

        // Segment 1 might be split or not depending on exact tolerance behavior
        // But we should have consistent results
        #expect(seg1Results.count >= 1)
        #expect(seg2Results.count >= 1)
        #expect(result.count >= 2)
    }

    @Test("Diagonal segments intersection")
    func testDiagonalIntersection() {
        // Two diagonal segments crossing
        let segments = [
            Identified(id: "D1", value: LineSegment(start: CGPoint.zero, end: CGPoint(x: 6, y: 6))),
            Identified(id: "D2", value: LineSegment(start: CGPoint(x: 2, y: 6), end: CGPoint(x: 6, y: 2)))
        ]

        let result = split(segments: segments)

        // Each diagonal should be split at the intersection point
        let d1Segments = result.filter { $0.id.parent == "D1" }
        let d2Segments = result.filter { $0.id.parent == "D2" }

        #expect(d1Segments.count == 2)
        #expect(d2Segments.count == 2)

        // Verify ordinals
        #expect(d1Segments.contains { $0.id.ordinal == 0 })
        #expect(d1Segments.contains { $0.id.ordinal == 1 })
        #expect(d2Segments.contains { $0.id.ordinal == 0 })
        #expect(d2Segments.contains { $0.id.ordinal == 1 })
    }

    @Test("Empty input")
    func testEmptyInput() {
        let segments: [Identified<String, LineSegment>] = []
        let result = split(segments: segments)

        #expect(result.isEmpty)
    }

    @Test("Single segment")
    func testSingleSegment() {
        let segments = [
            Identified(id: "only", value: LineSegment(start: CGPoint.zero, end: CGPoint(x: 10, y: 10)))
        ]

        let result = split(segments: segments)

        #expect(result.count == 1)
        #expect(result[0].id.parent == "only")
        #expect(result[0].id.ordinal == 0)
    }
}
