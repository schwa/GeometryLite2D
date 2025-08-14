import Testing
import Foundation
import CoreGraphics
import Geometry

@Suite("LineSegment Contains Tests")
struct LineSegmentContainsTests {
    
    @Test("LineSegment contains point basic cases")
    func testLineSegmentContainsPoint() {
        // Horizontal segment
        let horizontal = LineSegment(CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 0))
        
        // Points on the segment
        #expect(horizontal.contains(CGPoint(x: 0, y: 0), absoluteTolerance: 1e-5) == true)    // Start point
        #expect(horizontal.contains(CGPoint(x: 10, y: 0), absoluteTolerance: 1e-5) == true)   // End point
        #expect(horizontal.contains(CGPoint(x: 5, y: 0), absoluteTolerance: 1e-5) == true)    // Midpoint
        #expect(horizontal.contains(CGPoint(x: 2.5, y: 0), absoluteTolerance: 1e-5) == true)  // Quarter point
        
        // Points off the segment
        #expect(horizontal.contains(CGPoint(x: 5, y: 1), absoluteTolerance: 1e-5) == false)   // Above
        #expect(horizontal.contains(CGPoint(x: 5, y: -1), absoluteTolerance: 1e-5) == false)  // Below
        #expect(horizontal.contains(CGPoint(x: -1, y: 0), absoluteTolerance: 1e-5) == false)  // Before start
        #expect(horizontal.contains(CGPoint(x: 11, y: 0), absoluteTolerance: 1e-5) == false)  // Past end
        
        // Vertical segment
        let vertical = LineSegment(CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 10))
        
        #expect(vertical.contains(CGPoint(x: 0, y: 0), absoluteTolerance: 1e-5) == true)     // Start
        #expect(vertical.contains(CGPoint(x: 0, y: 10), absoluteTolerance: 1e-5) == true)    // End
        #expect(vertical.contains(CGPoint(x: 0, y: 5), absoluteTolerance: 1e-5) == true)     // Middle
        #expect(vertical.contains(CGPoint(x: 1, y: 5), absoluteTolerance: 1e-5) == false)    // To the right
        #expect(vertical.contains(CGPoint(x: -1, y: 5), absoluteTolerance: 1e-5) == false)   // To the left
        #expect(vertical.contains(CGPoint(x: 0, y: -1), absoluteTolerance: 1e-5) == false)   // Below
        #expect(vertical.contains(CGPoint(x: 0, y: 11), absoluteTolerance: 1e-5) == false)   // Above
        
        // Diagonal segment
        let diagonal = LineSegment(CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 10))
        
        #expect(diagonal.contains(CGPoint(x: 0, y: 0), absoluteTolerance: 1e-5) == true)     // Start
        #expect(diagonal.contains(CGPoint(x: 10, y: 10), absoluteTolerance: 1e-5) == true)   // End
        #expect(diagonal.contains(CGPoint(x: 5, y: 5), absoluteTolerance: 1e-5) == true)     // Middle
        #expect(diagonal.contains(CGPoint(x: 2, y: 2), absoluteTolerance: 1e-5) == true)     // On line
        #expect(diagonal.contains(CGPoint(x: 8, y: 8), absoluteTolerance: 1e-5) == true)     // On line
        #expect(diagonal.contains(CGPoint(x: 5, y: 6), absoluteTolerance: 1e-5) == false)    // Off line
        #expect(diagonal.contains(CGPoint(x: 6, y: 5), absoluteTolerance: 1e-5) == false)    // Off line
        #expect(diagonal.contains(CGPoint(x: -1, y: -1), absoluteTolerance: 1e-5) == false)  // Before start
        #expect(diagonal.contains(CGPoint(x: 11, y: 11), absoluteTolerance: 1e-5) == false)  // Past end
    }
    
    @Test("LineSegment contains point with tolerance")
    func testLineSegmentContainsPointTolerance() {
        let segment = LineSegment(CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 0))
        
        // Points very close to the segment (within tolerance)
        #expect(segment.contains(CGPoint(x: 5, y: 0.005), absoluteTolerance: 0.01) == true)
        #expect(segment.contains(CGPoint(x: 5, y: -0.005), absoluteTolerance: 0.01) == true)
        
        // Points just outside tolerance
        #expect(segment.contains(CGPoint(x: 5, y: 0.02), absoluteTolerance: 0.01) == false)
        #expect(segment.contains(CGPoint(x: 5, y: -0.02), absoluteTolerance: 0.01) == false)
        
        // Points near endpoints
        #expect(segment.contains(CGPoint(x: -0.005, y: 0), absoluteTolerance: 0.01) == true)
        #expect(segment.contains(CGPoint(x: 10.005, y: 0), absoluteTolerance: 0.01) == true)
        #expect(segment.contains(CGPoint(x: -0.02, y: 0), absoluteTolerance: 0.01) == false)
        #expect(segment.contains(CGPoint(x: 10.02, y: 0), absoluteTolerance: 0.01) == false)
    }
    
    @Test("LineSegment contains degenerate case")
    func testLineSegmentContainsDegenerateCase() {
        // Point segment (degenerate case)
        let point = LineSegment(CGPoint(x: 5, y: 5), CGPoint(x: 5, y: 5))
        
        #expect(point.contains(CGPoint(x: 5, y: 5), absoluteTolerance: 1e-5) == true)
        #expect(point.contains(CGPoint(x: 5.005, y: 5), absoluteTolerance: 0.01) == true)
        #expect(point.contains(CGPoint(x: 5, y: 5.005), absoluteTolerance: 0.01) == true)
        #expect(point.contains(CGPoint(x: 5.02, y: 5), absoluteTolerance: 0.01) == false)
        #expect(point.contains(CGPoint(x: 6, y: 5), absoluteTolerance: 1e-5) == false)
    }
    
    @Test("LineSegment contains another LineSegment")
    func testLineSegmentContainsLineSegment() {
        let segment = LineSegment(CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 0))
        
        // Segment contains itself
        #expect(segment.contains(segment) == true)
        
        // Subsegments
        #expect(segment.contains(LineSegment(CGPoint(x: 2, y: 0), CGPoint(x: 8, y: 0))) == true)
        #expect(segment.contains(LineSegment(CGPoint(x: 0, y: 0), CGPoint(x: 5, y: 0))) == true)
        #expect(segment.contains(LineSegment(CGPoint(x: 5, y: 0), CGPoint(x: 10, y: 0))) == true)
        
        // Segments that extend beyond
        #expect(segment.contains(LineSegment(CGPoint(x: -1, y: 0), CGPoint(x: 5, y: 0))) == false)
        #expect(segment.contains(LineSegment(CGPoint(x: 5, y: 0), CGPoint(x: 11, y: 0))) == false)
        #expect(segment.contains(LineSegment(CGPoint(x: -1, y: 0), CGPoint(x: 11, y: 0))) == false)
        
        // Parallel segments
        #expect(segment.contains(LineSegment(CGPoint(x: 0, y: 1), CGPoint(x: 10, y: 1))) == false)
        
        // Non-collinear segments
        #expect(segment.contains(LineSegment(CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 10))) == false)
        #expect(segment.contains(LineSegment(CGPoint(x: 5, y: -5), CGPoint(x: 5, y: 5))) == false)
    }
}