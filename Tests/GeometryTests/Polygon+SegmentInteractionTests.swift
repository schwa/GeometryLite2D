import CoreGraphics
import Foundation
import Geometry
import Testing

@Suite("Polygon Segment Interaction Tests")
struct PolygonSegmentInteractionTests {
    @Test("Square contains segment variations")
    func testSquareContainsSegmentVariations() {
        // Simple unit square
        let square = Polygon([
            CGPoint.zero,
            CGPoint(x: 10, y: 0),
            CGPoint(x: 10, y: 10),
            CGPoint(x: 0, y: 10)
        ])

        // Test 1: Segment fully inside (no contact with boundary)
        let fullyInside = LineSegment(CGPoint(x: 2, y: 2), CGPoint(x: 8, y: 8))
        #expect(square.contains(fullyInside) == true, "Fully inside diagonal should be contained")

        let horizontalInside = LineSegment(CGPoint(x: 2, y: 5), CGPoint(x: 8, y: 5))
        #expect(square.contains(horizontalInside) == true, "Horizontal segment inside should be contained")

        let verticalInside = LineSegment(CGPoint(x: 5, y: 2), CGPoint(x: 5, y: 8))
        #expect(square.contains(verticalInside) == true, "Vertical segment inside should be contained")

        // Test 2: Segment IS an edge (should be false - it's the boundary itself)
        let bottomEdge = LineSegment(CGPoint.zero, CGPoint(x: 10, y: 0))
        #expect(square.contains(bottomEdge) == false, "Bottom edge should not be contained")

        let topEdge = LineSegment(CGPoint(x: 10, y: 10), CGPoint(x: 0, y: 10))  // Reversed
        #expect(square.contains(topEdge) == false, "Top edge (reversed) should not be contained")

        let leftEdge = LineSegment(CGPoint.zero, CGPoint(x: 0, y: 10))
        #expect(square.contains(leftEdge) == false, "Left edge should not be contained")

        // Test 3: Partial edge (subset of an edge)
        let partialBottom = LineSegment(CGPoint(x: 2, y: 0), CGPoint(x: 8, y: 0))
        #expect(square.contains(partialBottom) == false, "Partial bottom edge should not be contained")

        let partialRight = LineSegment(CGPoint(x: 10, y: 2), CGPoint(x: 10, y: 8))
        #expect(square.contains(partialRight) == false, "Partial right edge should not be contained")

        // Test 4: Segment from vertex to vertex (diagonal)
        let cornerDiagonal = LineSegment(CGPoint.zero, CGPoint(x: 10, y: 10))
        #expect(square.contains(cornerDiagonal) == false, "Corner to corner diagonal should not be contained (endpoints on boundary)")

        let otherDiagonal = LineSegment(CGPoint(x: 0, y: 10), CGPoint(x: 10, y: 0))
        #expect(square.contains(otherDiagonal) == false, "Other corner diagonal should not be contained")

        // Test 5: Segment from edge to edge (cutting across)
        let edgeToEdge = LineSegment(CGPoint(x: 0, y: 5), CGPoint(x: 10, y: 5))
        #expect(square.contains(edgeToEdge) == false, "Edge to edge horizontal should not be contained (endpoints on boundary)")

        let verticalCut = LineSegment(CGPoint(x: 5, y: 0), CGPoint(x: 5, y: 10))
        #expect(square.contains(verticalCut) == false, "Edge to edge vertical should not be contained")

        // Test 6: Segment from inside to boundary
        let insideToBoundary = LineSegment(CGPoint(x: 5, y: 5), CGPoint(x: 10, y: 5))
        #expect(square.contains(insideToBoundary) == false, "Inside to boundary should not be contained (endpoint on boundary)")

        let insideToVertex = LineSegment(CGPoint(x: 5, y: 5), CGPoint(x: 10, y: 10))
        #expect(square.contains(insideToVertex) == false, "Inside to vertex should not be contained")

        // Test 7: Segment from boundary to inside
        let boundaryToInside = LineSegment(CGPoint(x: 0, y: 5), CGPoint(x: 5, y: 5))
        #expect(square.contains(boundaryToInside) == false, "Boundary to inside should not be contained (start on boundary)")

        let vertexToInside = LineSegment(CGPoint.zero, CGPoint(x: 5, y: 5))
        #expect(square.contains(vertexToInside) == false, "Vertex to inside should not be contained")

        // Test 8: Segment crossing through (endpoints outside)
        let crossingThrough = LineSegment(CGPoint(x: -2, y: 5), CGPoint(x: 12, y: 5))
        #expect(square.contains(crossingThrough) == false, "Segment crossing through should not be contained")

        let diagonalCrossing = LineSegment(CGPoint(x: -2, y: -2), CGPoint(x: 12, y: 12))
        #expect(square.contains(diagonalCrossing) == false, "Diagonal crossing should not be contained")

        // Test 9: Segment entirely outside
        let outside = LineSegment(CGPoint(x: 15, y: 15), CGPoint(x: 20, y: 20))
        #expect(square.contains(outside) == false, "Outside segment should not be contained")

        let parallel = LineSegment(CGPoint(x: -5, y: 5), CGPoint(x: -2, y: 5))
        #expect(square.contains(parallel) == false, "Parallel outside segment should not be contained")

        // Test 10: Segment touching boundary from outside
        let touchingCorner = LineSegment(CGPoint(x: -2, y: -2), CGPoint.zero)
        #expect(square.contains(touchingCorner) == false, "Segment touching corner from outside should not be contained")

        let touchingEdge = LineSegment(CGPoint(x: 5, y: -2), CGPoint(x: 5, y: 0))
        #expect(square.contains(touchingEdge) == false, "Segment touching edge from outside should not be contained")
    }

    @Test("Triangle contains segment variations")
    func testTriangleContainsSegmentVariations() {
        // Right triangle
        let triangle = Polygon([
            CGPoint.zero,
            CGPoint(x: 10, y: 0),
            CGPoint(x: 0, y: 10)
        ])

        // Fully inside
        let inside = LineSegment(CGPoint(x: 1, y: 1), CGPoint(x: 3, y: 3))
        #expect(triangle.contains(inside) == true, "Inside segment should be contained")

        // Edge segment
        let edge = LineSegment(CGPoint.zero, CGPoint(x: 10, y: 0))
        #expect(triangle.contains(edge) == false, "Edge should not be contained")

        // Hypotenuse
        let hypotenuse = LineSegment(CGPoint(x: 10, y: 0), CGPoint(x: 0, y: 10))
        #expect(triangle.contains(hypotenuse) == false, "Hypotenuse should not be contained")

        // Partial hypotenuse
        let partialHyp = LineSegment(CGPoint(x: 7, y: 3), CGPoint(x: 3, y: 7))
        #expect(triangle.contains(partialHyp) == false, "Partial hypotenuse should not be contained")

        // From vertex to inside
        let vertexToInside = LineSegment(CGPoint.zero, CGPoint(x: 2, y: 2))
        #expect(triangle.contains(vertexToInside) == false, "Vertex to inside should not be contained")

        // Crossing the hypotenuse
        let crossing = LineSegment(CGPoint(x: 2, y: 2), CGPoint(x: 8, y: 8))
        #expect(triangle.contains(crossing) == false, "Segment crossing hypotenuse should not be contained")

        // Outside
        let outside = LineSegment(CGPoint(x: 6, y: 6), CGPoint(x: 10, y: 10))
        #expect(triangle.contains(outside) == false, "Outside segment should not be contained")
    }

    @Test("Concave polygon contains segment")
    func testConcavePolygonContainsSegment() {
        // L-shaped polygon
        let lShape = Polygon([
            CGPoint.zero,
            CGPoint(x: 6, y: 0),
            CGPoint(x: 6, y: 3),
            CGPoint(x: 3, y: 3),
            CGPoint(x: 3, y: 6),
            CGPoint(x: 0, y: 6)
        ])

        // Inside the bottom part of L
        let bottomInside = LineSegment(CGPoint(x: 1, y: 1), CGPoint(x: 5, y: 1))
        #expect(lShape.contains(bottomInside) == true, "Bottom inside segment should be contained")

        // Inside the vertical part of L
        let verticalInside = LineSegment(CGPoint(x: 1, y: 4), CGPoint(x: 1, y: 5))
        #expect(lShape.contains(verticalInside) == true, "Vertical inside segment should be contained")

        // Crossing from one arm to another (valid)
        let armToArm = LineSegment(CGPoint(x: 1, y: 1), CGPoint(x: 1, y: 5))
        #expect(lShape.contains(armToArm) == true, "Segment from one arm to another should be contained")

        // In the notch (outside the L)
        let inNotch = LineSegment(CGPoint(x: 4, y: 4), CGPoint(x: 5, y: 5))
        #expect(lShape.contains(inNotch) == false, "Segment in notch should not be contained")

        // Crossing through the notch
        let crossNotch = LineSegment(CGPoint(x: 1, y: 1), CGPoint(x: 5, y: 5))
        #expect(lShape.contains(crossNotch) == false, "Segment crossing notch should not be contained")

        // Inner corner edge
        let innerCorner = LineSegment(CGPoint(x: 3, y: 3), CGPoint(x: 3, y: 6))
        #expect(lShape.contains(innerCorner) == false, "Inner corner edge should not be contained")

        // Crossing from inside to notch
        let insideToNotch = LineSegment(CGPoint(x: 2, y: 2), CGPoint(x: 4, y: 4))
        #expect(lShape.contains(insideToNotch) == false, "Inside to notch should not be contained")
    }

    @Test("Diamond contains segment")
    func testDiamondContainsSegment() {
        // Diamond/rhombus shape
        let diamond = Polygon([
            CGPoint(x: 5, y: 0),
            CGPoint(x: 10, y: 5),
            CGPoint(x: 5, y: 10),
            CGPoint(x: 0, y: 5)
        ])

        // Horizontal through center
        let horizontal = LineSegment(CGPoint(x: 2, y: 5), CGPoint(x: 8, y: 5))
        #expect(diamond.contains(horizontal) == true, "Horizontal through center should be contained")

        // Vertical through center
        let vertical = LineSegment(CGPoint(x: 5, y: 2), CGPoint(x: 5, y: 8))
        #expect(diamond.contains(vertical) == true, "Vertical through center should be contained")

        // Vertex to vertex
        let vertexToVertex = LineSegment(CGPoint(x: 5, y: 0), CGPoint(x: 5, y: 10))
        #expect(diamond.contains(vertexToVertex) == false, "Vertex to vertex should not be contained")

        // Edge
        let edge = LineSegment(CGPoint(x: 5, y: 0), CGPoint(x: 10, y: 5))
        #expect(diamond.contains(edge) == false, "Edge should not be contained")

        // From edge midpoint to edge midpoint
        let midToMid = LineSegment(CGPoint(x: 7.5, y: 2.5), CGPoint(x: 2.5, y: 7.5))
        #expect(diamond.contains(midToMid) == false, "Edge midpoint to edge midpoint should not be contained")
    }
}
