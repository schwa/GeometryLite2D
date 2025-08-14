import Testing
import Foundation
import CoreGraphics
@testable import FloorplanSupport


@Test
func testPolygonContainsSegmentEdgeCases() {
    // Test with a simple square
    let square = Polygon(vertices: [
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

@Test 
func testPolygonContainsSegmentWithConcavePolygon() {
    // L-shaped polygon (concave)
    let lShape = Polygon(vertices: [
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
    
    // Segment bridging across the notch
    #expect(lShape.contains(LineSegment(CGPoint(x: 2.0, y: 2.0), CGPoint(x: 2.0, y: 4.0))) == true)
    // This segment actually stays inside the L - it goes diagonally within the shape
    // The L extends from x=0 to x=6 at the bottom, and from y=0 to y=6 on the left
    // Point (4,2) is inside the bottom part, point (2,4) is inside the left part
    // The segment doesn't cross the notch, it stays within the L
    #expect(lShape.contains(LineSegment(CGPoint(x: 4.0, y: 2.0), CGPoint(x: 2.0, y: 4.0))) == true)
}