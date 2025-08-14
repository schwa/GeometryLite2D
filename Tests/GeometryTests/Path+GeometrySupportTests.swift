import CoreGraphics
@testable import Geometry
import SwiftUI
import Testing

@Suite("Path+GeometrySupport Tests")
struct PathGeometrySupportTests {
    
    // MARK: - Circle to Path Tests
    
    @Test("Path from Circle")
    func testPathFromCircle() {
        let circle = Circle(center: CGPoint(x: 5, y: 5), radius: 3)
        let path = Path(circle)
        
        // Path should not be empty
        #expect(!path.isEmpty)
        
        // The path should be roughly equivalent to an ellipse in a CGRect
        let expectedRect = CGRect(center: circle.center, radius: circle.radius)
        #expect(expectedRect.origin.x == 2.0)
        #expect(expectedRect.origin.y == 2.0)
        #expect(expectedRect.width == 6.0)
        #expect(expectedRect.height == 6.0)
    }
    
    @Test("Path from Circle at origin")
    func testPathFromCircleAtOrigin() {
        let circle = Circle(center: .zero, radius: 1)
        let path = Path(circle)
        
        #expect(!path.isEmpty)
    }
    
    @Test("Path from Circle with zero radius")
    func testPathFromCircleWithZeroRadius() {
        let circle = Circle(center: CGPoint(x: 2, y: 3), radius: 0)
        let path = Path(circle)
        
        // Even with zero radius, path should be created (just a point)
        #expect(!path.isEmpty)
    }
    
    // MARK: - Line to Path Tests
    
    @Test("Path from Line")
    func testPathFromLine() {
        let line = Line(point: CGPoint(x: 0, y: 0), direction: CGVector(dx: 1, dy: 1))
        let path = Path(line)
        
        #expect(!path.isEmpty)
        
        // The line should extend far in both directions from the point
        // We can't easily test the exact path contents, but we can verify it's not empty
    }
    
    @Test("Path from vertical Line")
    func testPathFromVerticalLine() {
        let line = Line(point: CGPoint(x: 5, y: 10), direction: CGVector(dx: 0, dy: 1))
        let path = Path(line)
        
        #expect(!path.isEmpty)
    }
    
    @Test("Path from horizontal Line")
    func testPathFromHorizontalLine() {
        let line = Line(point: CGPoint(x: 10, y: 5), direction: CGVector(dx: 1, dy: 0))
        let path = Path(line)
        
        #expect(!path.isEmpty)
    }
    
    // MARK: - LineSegment to Path Tests
    
    @Test("Path from LineSegment")
    func testPathFromLineSegment() {
        let segment = LineSegment(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 10, y: 10))
        let path = Path(segment)
        
        #expect(!path.isEmpty)
    }
    
    @Test("Path from zero-length LineSegment")
    func testPathFromZeroLengthLineSegment() {
        let segment = LineSegment(start: CGPoint(x: 5, y: 5), end: CGPoint(x: 5, y: 5))
        let path = Path(segment)
        
        #expect(!path.isEmpty)
    }
    
    @Test("Path from multiple LineSegments")
    func testPathFromMultipleLineSegments() {
        let segments = [
            LineSegment(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 5, y: 0)),
            LineSegment(start: CGPoint(x: 10, y: 10), end: CGPoint(x: 15, y: 15)),
            LineSegment(start: CGPoint(x: 20, y: 0), end: CGPoint(x: 20, y: 10))
        ]
        
        let path = Path(segments: segments)
        
        #expect(!path.isEmpty)
    }
    
    @Test("Path from empty LineSegments array")
    func testPathFromEmptyLineSegments() {
        let segments: [LineSegment] = []
        let path = Path(segments: segments)
        
        // Path should be empty for empty segments array
        #expect(path.isEmpty)
    }
    
    @Test("Path from single LineSegment in array")
    func testPathFromSingleLineSegmentInArray() {
        let segments = [LineSegment(start: CGPoint(x: 1, y: 2), end: CGPoint(x: 3, y: 4))]
        let path = Path(segments: segments)
        
        #expect(!path.isEmpty)
    }
    
    // MARK: - Polygon to Path Tests
    
    @Test("Path from triangle Polygon")
    func testPathFromTrianglePolygon() {
        let polygon = Polygon([
            CGPoint(x: 0, y: 0),
            CGPoint(x: 5, y: 0),
            CGPoint(x: 2.5, y: 5)
        ])
        
        let path = Path(polygon)
        
        #expect(!path.isEmpty)
    }
    
    @Test("Path from square Polygon")
    func testPathFromSquarePolygon() {
        let polygon = Polygon([
            CGPoint(x: 0, y: 0),
            CGPoint(x: 10, y: 0),
            CGPoint(x: 10, y: 10),
            CGPoint(x: 0, y: 10)
        ])
        
        let path = Path(polygon)
        
        #expect(!path.isEmpty)
    }
    
    @Test("Path from single point Polygon")  
    func testPathFromSinglePointPolygon() {
        // Note: Single point polygons aren't valid, so we test minimal valid polygon
        let polygon = Polygon([
            CGPoint(x: 0, y: 0),
            CGPoint(x: 1, y: 0), 
            CGPoint(x: 0, y: 1)
        ])
        let path = Path(polygon)
        
        #expect(!path.isEmpty)
    }
    
    @Test("Path from valid Polygon")
    func testPathFromValidPolygon() {
        let polygon = Polygon([
            CGPoint(x: 0, y: 0),
            CGPoint(x: 5, y: 0),
            CGPoint(x: 5, y: 5)
        ])
        
        let path = Path(polygon)
        
        #expect(!path.isEmpty)
    }
    
    // MARK: - Ray to Path Tests
    
    @Test("Path from Ray")
    func testPathFromRay() {
        let ray = Ray(origin: CGPoint(x: 0, y: 0), direction: CGVector(dx: 1, dy: 1))
        let path = Path(ray)
        
        #expect(!path.isEmpty)
    }
    
    @Test("Path from Ray with horizontal direction")
    func testPathFromRayHorizontal() {
        let ray = Ray(origin: CGPoint(x: 5, y: 5), direction: CGVector(dx: 1, dy: 0))
        let path = Path(ray)
        
        #expect(!path.isEmpty)
    }
    
    @Test("Path from Ray with vertical direction")
    func testPathFromRayVertical() {
        let ray = Ray(origin: CGPoint(x: 5, y: 5), direction: CGVector(dx: 0, dy: 1))
        let path = Path(ray)
        
        #expect(!path.isEmpty)
    }
    
    @Test("Path from Ray within bounds that intersects")
    func testPathFromRayWithinBoundsIntersects() {
        let ray = Ray(origin: CGPoint(x: 5, y: 5), direction: CGVector(dx: 1, dy: 0))
        let bounds = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        let path = Path(ray, within: bounds)
        
        #expect(!path.isEmpty)
    }
    
    @Test("Path from Ray within bounds that doesn't intersect")
    func testPathFromRayWithinBoundsNoIntersection() {
        // Ray pointing away from bounds
        let ray = Ray(origin: CGPoint(x: 25, y: 25), direction: CGVector(dx: 1, dy: 1))
        let bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
        
        let path = Path(ray, within: bounds)
        
        // Path should be empty when ray doesn't intersect bounds
        #expect(path.isEmpty)
    }
    
    @Test("Path from Ray starting inside bounds")
    func testPathFromRayStartingInsideBounds() {
        let ray = Ray(origin: CGPoint(x: 5, y: 5), direction: CGVector(dx: 1, dy: 1))
        let bounds = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        let path = Path(ray, within: bounds)
        
        #expect(!path.isEmpty)
    }
    
    @Test("Path from Ray starting on bounds edge")
    func testPathFromRayStartingOnBoundsEdge() {
        let ray = Ray(origin: CGPoint(x: 0, y: 5), direction: CGVector(dx: 1, dy: 0))
        let bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
        
        let path = Path(ray, within: bounds)
        
        #expect(!path.isEmpty)
    }
    
    @Test("Path from Ray with zero bounds")
    func testPathFromRayWithZeroBounds() {
        let ray = Ray(origin: CGPoint(x: 0, y: 0), direction: CGVector(dx: 1, dy: 1))
        let bounds = CGRect.zero
        
        let path = Path(ray, within: bounds)
        
        // Should handle zero-sized bounds gracefully
        #expect(path.isEmpty)
    }
}
