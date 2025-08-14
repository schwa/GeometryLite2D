import Testing
import CoreGraphics
@testable import Geometry

@Suite
struct ConvexHullAlgorithmsTests {
    
    @Test
    func testBothAlgorithmsProduceSameResult() {
        // Test with a simple set of points
        let points: [CGPoint] = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 1, y: 0),
            CGPoint(x: 2, y: 1),
            CGPoint(x: 1, y: 2),
            CGPoint(x: 0, y: 1),
            CGPoint(x: 0.5, y: 0.5) // Interior point
        ]
        
        let defaultHull = Set(convexHull(points))
        let andrewHull = Set(convexHullAndrewMonotoneChain(points))
        let grahamHull = Set(convexHullGrahamScan(points))
        
        // All three should produce the same set of hull points
        #expect(defaultHull == andrewHull)
        #expect(andrewHull == grahamHull)
        
        // Verify the hull has the expected points (corners of the shape)
        let expectedHull: Set<CGPoint> = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 1, y: 0),
            CGPoint(x: 2, y: 1),
            CGPoint(x: 1, y: 2),
            CGPoint(x: 0, y: 1)
        ]
        
        #expect(defaultHull == expectedHull)
        #expect(andrewHull == expectedHull)
        #expect(grahamHull == expectedHull)
    }
    
    @Test
    func testDefaultAlgorithmIsAndrews() {
        // Test that the default convexHull function uses Andrew's algorithm
        let points: [CGPoint] = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 2, y: 0),
            CGPoint(x: 1, y: 1),
            CGPoint(x: 0.5, y: 0.25)
        ]
        
        let defaultResult = convexHull(points)
        let andrewResult = convexHullAndrewMonotoneChain(points)
        
        // They should produce exactly the same result (same order too)
        #expect(defaultResult == andrewResult)
    }
    
    @Test
    func testGrahamScanWithRandomPoints() {
        // Generate random points
        let points: [CGPoint] = (0..<20).map { _ in
            CGPoint(
                x: CGFloat.random(in: -10...10),
                y: CGFloat.random(in: -10...10)
            )
        }
        
        let hull = convexHullGrahamScan(points)
        
        // Basic sanity checks
        #expect(hull.count >= 3 || hull.count == points.count)
        
        // All hull points should be from the original set
        for point in hull {
            #expect(points.contains(point))
        }
    }
    
    @Test
    func testGrahamScanWithCollinearPoints() {
        // Points on a line
        let points: [CGPoint] = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 1, y: 1),
            CGPoint(x: 2, y: 2),
            CGPoint(x: 3, y: 3)
        ]
        
        let hull = convexHullGrahamScan(points)
        
        // For collinear points, hull should just be the endpoints
        #expect(hull.count == 2)
        #expect(hull.contains(CGPoint(x: 0, y: 0)))
        #expect(hull.contains(CGPoint(x: 3, y: 3)))
    }
    
    @Test
    func testGrahamScanWithSquare() {
        let points: [CGPoint] = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 1, y: 0),
            CGPoint(x: 1, y: 1),
            CGPoint(x: 0, y: 1),
            CGPoint(x: 0.5, y: 0.5) // Center point
        ]
        
        let hull = convexHullGrahamScan(points)
        
        // Hull should be the 4 corners
        #expect(hull.count == 4)
        
        let hullSet = Set(hull)
        let expectedCorners: Set<CGPoint> = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 1, y: 0),
            CGPoint(x: 1, y: 1),
            CGPoint(x: 0, y: 1)
        ]
        
        #expect(hullSet == expectedCorners)
    }
}