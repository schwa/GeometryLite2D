import Testing
import Foundation
import CoreGraphics
@testable import FloorplanSupport

@Test
func testLineSegmentContainsPoint() {
    // Horizontal segment
    let horizontal = LineSegment(CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 0))
    
    // Points on the segment
    #expect(horizontal.contains(CGPoint(x: 0, y: 0)) == true)    // Start point
    #expect(horizontal.contains(CGPoint(x: 10, y: 0)) == true)   // End point
    #expect(horizontal.contains(CGPoint(x: 5, y: 0)) == true)    // Midpoint
    #expect(horizontal.contains(CGPoint(x: 2.5, y: 0)) == true)  // Quarter point
    
    // Points off the segment
    #expect(horizontal.contains(CGPoint(x: 5, y: 1)) == false)   // Above
    #expect(horizontal.contains(CGPoint(x: 5, y: -1)) == false)  // Below
    #expect(horizontal.contains(CGPoint(x: -1, y: 0)) == false)  // Before start
    #expect(horizontal.contains(CGPoint(x: 11, y: 0)) == false)  // Past end
    
    // Vertical segment
    let vertical = LineSegment(CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 10))
    
    #expect(vertical.contains(CGPoint(x: 0, y: 0)) == true)     // Start
    #expect(vertical.contains(CGPoint(x: 0, y: 10)) == true)    // End
    #expect(vertical.contains(CGPoint(x: 0, y: 5)) == true)     // Middle
    #expect(vertical.contains(CGPoint(x: 1, y: 5)) == false)    // To the right
    #expect(vertical.contains(CGPoint(x: -1, y: 5)) == false)   // To the left
    #expect(vertical.contains(CGPoint(x: 0, y: -1)) == false)   // Below
    #expect(vertical.contains(CGPoint(x: 0, y: 11)) == false)   // Above
    
    // Diagonal segment
    let diagonal = LineSegment(CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 10))
    
    #expect(diagonal.contains(CGPoint(x: 0, y: 0)) == true)     // Start
    #expect(diagonal.contains(CGPoint(x: 10, y: 10)) == true)   // End
    #expect(diagonal.contains(CGPoint(x: 5, y: 5)) == true)     // Middle
    #expect(diagonal.contains(CGPoint(x: 2, y: 2)) == true)     // On line
    #expect(diagonal.contains(CGPoint(x: 8, y: 8)) == true)     // On line
    #expect(diagonal.contains(CGPoint(x: 5, y: 6)) == false)    // Off line
    #expect(diagonal.contains(CGPoint(x: 6, y: 5)) == false)    // Off line
    #expect(diagonal.contains(CGPoint(x: -1, y: -1)) == false)  // Before start
    #expect(diagonal.contains(CGPoint(x: 11, y: 11)) == false)  // Past end
}

@Test
func testLineSegmentContainsPointTolerance() {
    let segment = LineSegment(CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 0))
    
    // Points very close to the segment (within tolerance)
    #expect(segment.contains(CGPoint(x: 5, y: 0.005), tolerance: 0.01) == true)
    #expect(segment.contains(CGPoint(x: 5, y: -0.005), tolerance: 0.01) == true)
    
    // Points just outside tolerance
    #expect(segment.contains(CGPoint(x: 5, y: 0.02), tolerance: 0.01) == false)
    #expect(segment.contains(CGPoint(x: 5, y: -0.02), tolerance: 0.01) == false)
    
    // Points near endpoints
    #expect(segment.contains(CGPoint(x: -0.005, y: 0), tolerance: 0.01) == true)
    #expect(segment.contains(CGPoint(x: 10.005, y: 0), tolerance: 0.01) == true)
    #expect(segment.contains(CGPoint(x: -0.02, y: 0), tolerance: 0.01) == false)
    #expect(segment.contains(CGPoint(x: 10.02, y: 0), tolerance: 0.01) == false)
}

@Test
func testLineSegmentContainsDegenerateCase() {
    // Point segment (degenerate case)
    let point = LineSegment(CGPoint(x: 5, y: 5), CGPoint(x: 5, y: 5))
    
    #expect(point.contains(CGPoint(x: 5, y: 5)) == true)
    #expect(point.contains(CGPoint(x: 5.005, y: 5), tolerance: 0.01) == true)
    #expect(point.contains(CGPoint(x: 5, y: 5.005), tolerance: 0.01) == true)
    #expect(point.contains(CGPoint(x: 5.02, y: 5), tolerance: 0.01) == false)
    #expect(point.contains(CGPoint(x: 6, y: 5)) == false)
}

@Test
func testPolygonContainsPointWithBoundary() {
    // Simple square
    let square = Polygon(vertices: [
        CGPoint(x: 0, y: 0),
        CGPoint(x: 10, y: 0),
        CGPoint(x: 10, y: 10),
        CGPoint(x: 0, y: 10)
    ])
    
    // Interior points
    #expect(square.contains(CGPoint(x: 5, y: 5)) == true)
    #expect(square.contains(CGPoint(x: 1, y: 1)) == true)
    #expect(square.contains(CGPoint(x: 9, y: 9)) == true)
    
    // Boundary points - ALL should be inside now
    #expect(square.contains(CGPoint(x: 0, y: 0)) == true)    // Vertex
    #expect(square.contains(CGPoint(x: 10, y: 0)) == true)   // Vertex
    #expect(square.contains(CGPoint(x: 10, y: 10)) == true)  // Vertex
    #expect(square.contains(CGPoint(x: 0, y: 10)) == true)   // Vertex
    
    #expect(square.contains(CGPoint(x: 5, y: 0)) == true)    // Bottom edge
    #expect(square.contains(CGPoint(x: 10, y: 5)) == true)   // Right edge
    #expect(square.contains(CGPoint(x: 5, y: 10)) == true)   // Top edge
    #expect(square.contains(CGPoint(x: 0, y: 5)) == true)    // Left edge
    
    // Exterior points
    #expect(square.contains(CGPoint(x: -1, y: 5)) == false)
    #expect(square.contains(CGPoint(x: 11, y: 5)) == false)
    #expect(square.contains(CGPoint(x: 5, y: -1)) == false)
    #expect(square.contains(CGPoint(x: 5, y: 11)) == false)
    #expect(square.contains(CGPoint(x: -1, y: -1)) == false)
}

@Test
func testPolygonContainsPointConcave() {
    // L-shaped polygon (concave)
    let lShape = Polygon(vertices: [
        CGPoint(x: 0, y: 0),
        CGPoint(x: 6, y: 0),
        CGPoint(x: 6, y: 3),
        CGPoint(x: 3, y: 3),
        CGPoint(x: 3, y: 6),
        CGPoint(x: 0, y: 6)
    ])
    
    // Points inside the L
    #expect(lShape.contains(CGPoint(x: 1, y: 1)) == true)
    #expect(lShape.contains(CGPoint(x: 5, y: 1)) == true)
    #expect(lShape.contains(CGPoint(x: 1, y: 5)) == true)
    
    // Points in the concave region (outside)
    #expect(lShape.contains(CGPoint(x: 4, y: 4)) == false)
    #expect(lShape.contains(CGPoint(x: 5, y: 5)) == false)
    
    // Points on the boundary (all should be inside)
    #expect(lShape.contains(CGPoint(x: 0, y: 0)) == true)
    #expect(lShape.contains(CGPoint(x: 6, y: 0)) == true)
    #expect(lShape.contains(CGPoint(x: 3, y: 3)) == true)  // Inner corner
    #expect(lShape.contains(CGPoint(x: 6, y: 3)) == true)  // Outer corner
    #expect(lShape.contains(CGPoint(x: 3, y: 0)) == true)  // Edge point
    #expect(lShape.contains(CGPoint(x: 0, y: 3)) == true)  // Edge point
}

@Test
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