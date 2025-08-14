import Testing
import Foundation
import CoreGraphics
import Geometry

@Suite("Polygon Contains Segment Tests")
struct PolygonContainsSegmentTests {
    
    @Test("Polygon contains segment edge cases")
    func testPolygonContainsSegmentEdgeCases() {
        // Test with a simple square
        let square = Polygon([
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 10.0, y: 0.0),
            CGPoint(x: 10.0, y: 10.0),
            CGPoint(x: 0.0, y: 10.0)
        ])
        
        // Diagonal inside
        #expect(square.contains(LineSegment(CGPoint(x: 2.0, y: 2.0), CGPoint(x: 8.0, y: 8.0))) == true)
        
        // Horizontal inside
        #expect(square.contains(LineSegment(CGPoint(x: 2.0, y: 5.0), CGPoint(x: 8.0, y: 5.0))) == true)
        
        // Vertical inside
        #expect(square.contains(LineSegment(CGPoint(x: 5.0, y: 2.0), CGPoint(x: 5.0, y: 8.0))) == true)
        
        // Edge of square
        #expect(square.contains(LineSegment(CGPoint(x: 0.0, y: 0.0), CGPoint(x: 10.0, y: 0.0))) == false)
        
        // Partial edge
        #expect(square.contains(LineSegment(CGPoint(x: 2.0, y: 0.0), CGPoint(x: 8.0, y: 0.0))) == false)
        
        // Corner to corner diagonal (through the square)
        #expect(square.contains(LineSegment(CGPoint(x: 0.0, y: 0.0), CGPoint(x: 10.0, y: 10.0))) == false)
        
        // Segment touching edge from inside
        #expect(square.contains(LineSegment(CGPoint(x: 5.0, y: 5.0), CGPoint(x: 10.0, y: 5.0))) == false)
        
        // Very small segment inside
        #expect(square.contains(LineSegment(CGPoint(x: 5.0, y: 5.0), CGPoint(x: 5.01, y: 5.01))) == true)
    }
    
    @Test("Polygon contains segment with concave polygon")
    func testPolygonContainsSegmentWithConcavePolygon() {
        // L-shaped polygon (concave)
        let lShape = Polygon([
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 6.0, y: 0.0),
            CGPoint(x: 6.0, y: 3.0),
            CGPoint(x: 3.0, y: 3.0),
            CGPoint(x: 3.0, y: 6.0),
            CGPoint(x: 0.0, y: 6.0)
        ])
        
        // Segment inside the L
        #expect(lShape.contains(LineSegment(CGPoint(x: 1.0, y: 1.0), CGPoint(x: 2.0, y: 2.0))) == true)
        #expect(lShape.contains(LineSegment(CGPoint(x: 4.0, y: 1.0), CGPoint(x: 5.0, y: 2.0))) == true)
        #expect(lShape.contains(LineSegment(CGPoint(x: 1.0, y: 4.0), CGPoint(x: 2.0, y: 5.0))) == true)
        
        // Segment crossing the concave part (outside the L, in the notch)
        #expect(lShape.contains(LineSegment(CGPoint(x: 4.0, y: 4.0), CGPoint(x: 5.0, y: 5.0))) == false)
        
        // Segment from inside to the notch
        #expect(lShape.contains(LineSegment(CGPoint(x: 2.0, y: 2.0), CGPoint(x: 4.0, y: 4.0))) == false)
        
        // Segment bridging across the notch but staying inside
        #expect(lShape.contains(LineSegment(CGPoint(x: 2.0, y: 2.0), CGPoint(x: 2.0, y: 4.0))) == true)
        
        // This segment goes from the bottom part to the left part without crossing the notch
        #expect(lShape.contains(LineSegment(CGPoint(x: 4.0, y: 2.0), CGPoint(x: 2.0, y: 4.0))) == true)
    }
    
    @Test("Polygon contains point with boundary")
    func testPolygonContainsPointWithBoundary() {
        // Simple square
        let square = Polygon([
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
    
    @Test("Polygon contains point concave")
    func testPolygonContainsPointConcave() {
        // L-shaped polygon (concave)
        let lShape = Polygon([
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
}