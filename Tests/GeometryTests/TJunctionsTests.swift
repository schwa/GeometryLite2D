import CoreGraphics
import Geometry
import Testing

@Suite("TJunctions Resolution Tests")
struct TJunctionsTests {
    
    @Test("Basic T-junction resolution")
    func testBasicTJunction() {
        // Create a T-junction: horizontal segment with vertical segment ending at its midpoint
        let horizontal = LineSegment(start: CGPoint(x: 0, y: 5), end: CGPoint(x: 10, y: 5))
        let vertical = LineSegment(start: CGPoint(x: 5, y: 0), end: CGPoint(x: 5, y: 5))
        
        let result = resolveTJunctions(segments: [horizontal, vertical], absoluteTolerance: 1e-10)
        
        // Horizontal should be split into 2 segments
        #expect(result[horizontal]?.count == 2)
        
        // Vertical should remain as 1 segment
        #expect(result[vertical]?.count == 1)
        
        // Check the split segments
        if let horizontalSegments = result[horizontal], horizontalSegments.count == 2 {
            let sorted = horizontalSegments.sorted { $0.start.x < $1.start.x }
            #expect(sorted[0].start.isApproximatelyEqual(to: CGPoint(x: 0, y: 5), absoluteTolerance: 1e-10))
            #expect(sorted[0].end.isApproximatelyEqual(to: CGPoint(x: 5, y: 5), absoluteTolerance: 1e-10))
            #expect(sorted[1].start.isApproximatelyEqual(to: CGPoint(x: 5, y: 5), absoluteTolerance: 1e-10))
            #expect(sorted[1].end.isApproximatelyEqual(to: CGPoint(x: 10, y: 5), absoluteTolerance: 1e-10))
        }
    }
    
    @Test("Multiple T-junctions on single segment")
    func testMultipleTJunctions() {
        // One horizontal segment with two vertical segments forming T-junctions
        let horizontal = LineSegment(start: CGPoint(x: 0, y: 5), end: CGPoint(x: 10, y: 5))
        let vertical1 = LineSegment(start: CGPoint(x: 3, y: 0), end: CGPoint(x: 3, y: 5))
        let vertical2 = LineSegment(start: CGPoint(x: 7, y: 0), end: CGPoint(x: 7, y: 5))
        
        let result = resolveTJunctions(segments: [horizontal, vertical1, vertical2], absoluteTolerance: 1e-10)
        
        // Horizontal should be split into 3 segments
        #expect(result[horizontal]?.count == 3)
        
        // Verticals should remain as single segments
        #expect(result[vertical1]?.count == 1)
        #expect(result[vertical2]?.count == 1)
        
        // Verify the splits
        if let horizontalSegments = result[horizontal], horizontalSegments.count == 3 {
            let sorted = horizontalSegments.sorted { $0.start.x < $1.start.x }
            #expect(sorted[0].start.x.isApproximatelyEqual(to: 0, absoluteTolerance: 1e-10))
            #expect(sorted[0].end.x.isApproximatelyEqual(to: 3, absoluteTolerance: 1e-10))
            #expect(sorted[1].start.x.isApproximatelyEqual(to: 3, absoluteTolerance: 1e-10))
            #expect(sorted[1].end.x.isApproximatelyEqual(to: 7, absoluteTolerance: 1e-10))
            #expect(sorted[2].start.x.isApproximatelyEqual(to: 7, absoluteTolerance: 1e-10))
            #expect(sorted[2].end.x.isApproximatelyEqual(to: 10, absoluteTolerance: 1e-10))
        }
    }
    
    @Test("No T-junctions - segments don't touch")
    func testNoTJunctions() {
        let segment1 = LineSegment(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 10, y: 0))
        let segment2 = LineSegment(start: CGPoint(x: 0, y: 5), end: CGPoint(x: 10, y: 5))
        
        let result = resolveTJunctions(segments: [segment1, segment2], absoluteTolerance: 1e-10)
        
        // Both segments should remain unchanged
        #expect(result[segment1]?.count == 1)
        #expect(result[segment2]?.count == 1)
        #expect(result[segment1]?[0] == segment1)
        #expect(result[segment2]?[0] == segment2)
    }
    
    @Test("Cross intersection (not T-junction)")
    func testCrossIntersection() {
        // Two segments that cross but don't form a T-junction
        let segment1 = LineSegment(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 10, y: 10))
        let segment2 = LineSegment(start: CGPoint(x: 0, y: 10), end: CGPoint(x: 10, y: 0))
        
        let result = resolveTJunctions(segments: [segment1, segment2], absoluteTolerance: 1e-10)
        
        // Neither segment should be split (endpoints don't touch the other segment)
        #expect(result[segment1]?.count == 1)
        #expect(result[segment2]?.count == 1)
    }
    
    @Test("Chain of T-junctions")
    func testChainedTJunctions() {
        // Create segments that form chained T-junctions
        let horizontal1 = LineSegment(start: CGPoint(x: 0, y: 2), end: CGPoint(x: 6, y: 2))
        let horizontal2 = LineSegment(start: CGPoint(x: 2, y: 4), end: CGPoint(x: 8, y: 4))
        let vertical = LineSegment(start: CGPoint(x: 2, y: 0), end: CGPoint(x: 2, y: 4))
        
        let result = resolveTJunctions(segments: [horizontal1, horizontal2, vertical], absoluteTolerance: 1e-10)
        
        // The algorithm only splits segments when their endpoints touch other segments' interiors
        // horizontal1 is not split because vertical's end is at (2,4), not in horizontal1's interior
        #expect(result[horizontal1]?.count == 1)
        
        // horizontal2 should not be split (vertical ends at it, not passing through)
        #expect(result[horizontal2]?.count == 1)
        
        // vertical is not split because horizontal1's point (2,2) isn't an endpoint that touches vertical's interior
        #expect(result[vertical]?.count == 1)
    }
    
    @Test("T-junction with tolerance")
    func testTJunctionWithTolerance() {
        // Create a near T-junction within tolerance
        let horizontal = LineSegment(start: CGPoint(x: 0, y: 5), end: CGPoint(x: 10, y: 5))
        let vertical = LineSegment(start: CGPoint(x: 5, y: 0), end: CGPoint(x: 5, y: 5.00001))
        
        let result = resolveTJunctions(segments: [horizontal, vertical], absoluteTolerance: 1e-4)
        
        // With tolerance, this should be treated as a T-junction
        #expect(result[horizontal]?.count == 2)
        #expect(result[vertical]?.count == 1)
    }
    
    @Test("T-junction outside tolerance")
    func testTJunctionOutsideTolerance() {
        // Create a near T-junction outside tolerance
        let horizontal = LineSegment(start: CGPoint(x: 0, y: 5), end: CGPoint(x: 10, y: 5))
        let vertical = LineSegment(start: CGPoint(x: 5, y: 0), end: CGPoint(x: 5, y: 5.1))
        
        let result = resolveTJunctions(segments: [horizontal, vertical], absoluteTolerance: 1e-4)
        
        // Outside tolerance, this should not be treated as a T-junction
        #expect(result[horizontal]?.count == 1)
        #expect(result[vertical]?.count == 1)
    }
    
    @Test("Empty segments")
    func testEmptySegments() {
        let result = resolveTJunctions(segments: [], absoluteTolerance: 1e-10)
        #expect(result.isEmpty)
    }
    
    @Test("Single segment")
    func testSingleSegment() {
        let segment = LineSegment(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 10, y: 10))
        let result = resolveTJunctions(segments: [segment], absoluteTolerance: 1e-10)
        
        #expect(result[segment]?.count == 1)
        #expect(result[segment]?[0] == segment)
    }
    
    @Test("Complex grid pattern")
    func testComplexGrid() {
        // Create a grid where T-junctions may or may not form
        let horizontal1 = LineSegment(start: CGPoint(x: 0, y: 2), end: CGPoint(x: 6, y: 2))
        let horizontal2 = LineSegment(start: CGPoint(x: 0, y: 4), end: CGPoint(x: 6, y: 4))
        let vertical1 = LineSegment(start: CGPoint(x: 2, y: 0), end: CGPoint(x: 2, y: 6))
        let vertical2 = LineSegment(start: CGPoint(x: 4, y: 0), end: CGPoint(x: 4, y: 6))
        
        let result = resolveTJunctions(segments: [horizontal1, horizontal2, vertical1, vertical2], absoluteTolerance: 1e-10)
        
        // The algorithm only splits when endpoints touch interiors
        // Since none of the endpoints are in the interior of other segments, no splits occur
        #expect(result[horizontal1]?.count == 1)
        #expect(result[horizontal2]?.count == 1)
        #expect(result[vertical1]?.count == 1)
        #expect(result[vertical2]?.count == 1)
    }
    
    @Test("T-junction at segment start")
    func testTJunctionAtStart() {
        let horizontal = LineSegment(start: CGPoint(x: 0, y: 5), end: CGPoint(x: 10, y: 5))
        let vertical = LineSegment(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: 5))
        
        let result = resolveTJunctions(segments: [horizontal, vertical], absoluteTolerance: 1e-10)
        
        // No split should occur as the T-junction is at the start point
        #expect(result[horizontal]?.count == 1)
        #expect(result[vertical]?.count == 1)
    }
    
    @Test("T-junction at segment end")
    func testTJunctionAtEnd() {
        let horizontal = LineSegment(start: CGPoint(x: 0, y: 5), end: CGPoint(x: 10, y: 5))
        let vertical = LineSegment(start: CGPoint(x: 10, y: 0), end: CGPoint(x: 10, y: 5))
        
        let result = resolveTJunctions(segments: [horizontal, vertical], absoluteTolerance: 1e-10)
        
        // No split should occur as the T-junction is at the end point
        #expect(result[horizontal]?.count == 1)
        #expect(result[vertical]?.count == 1)
    }
    
    @Test("Collinear segments")
    func testCollinearSegments() {
        // Two collinear segments with one endpoint touching the other segment
        let segment1 = LineSegment(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 5, y: 0))
        let segment2 = LineSegment(start: CGPoint(x: 3, y: 0), end: CGPoint(x: 8, y: 0))
        
        let result = resolveTJunctions(segments: [segment1, segment2], absoluteTolerance: 1e-10)
        
        // segment1 should be split at x=3
        #expect(result[segment1]?.count == 2)
        // segment2 should be split at x=5
        #expect(result[segment2]?.count == 2)
    }
}