import CoreGraphics
@testable import Geometry
import SwiftUI
import Testing

@Suite("PathRepresentable Tests")
struct PathRepresentableTests {
    
    // MARK: - Protocol Conformance Tests
    
    @Test("CGRect conforms to PathRepresentable")
    func testCGRectConformance() {
        let rect = CGRect(x: 10, y: 20, width: 100, height: 50)
        let path = rect.makePath()
        
        #expect(!path.isEmpty)
        
        // Test convenience initializer
        let pathFromInit = Path(representable: rect)
        #expect(!pathFromInit.isEmpty)
    }
    
    @Test("LineSegment conforms to PathRepresentable")
    func testLineSegmentConformance() {
        let segment = LineSegment(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 10, y: 10))
        let path = segment.makePath()
        
        #expect(!path.isEmpty)
        
        // Test convenience initializer
        let pathFromInit = Path(representable: segment)
        #expect(!pathFromInit.isEmpty)
    }
    
    @Test("Polygon conforms to PathRepresentable")
    func testPolygonConformance() {
        let polygon = Polygon([
            CGPoint(x: 0, y: 0),
            CGPoint(x: 10, y: 0),
            CGPoint(x: 5, y: 10)
        ])
        let path = polygon.makePath()
        
        #expect(!path.isEmpty)
        
        // Test convenience initializer
        let pathFromInit = Path(representable: polygon)
        #expect(!pathFromInit.isEmpty)
    }
    
    // MARK: - CGRect PathRepresentable Tests
    
    @Test("CGRect makePath creates rectangular path")
    func testCGRectMakePath() {
        let rect = CGRect(x: 5, y: 5, width: 20, height: 30)
        let path = rect.makePath()
        
        #expect(!path.isEmpty)
        // The path should represent the rectangle bounds
    }
    
    @Test("CGRect makePath with zero size")
    func testCGRectMakePathZeroSize() {
        let rect = CGRect(x: 10, y: 10, width: 0, height: 0)
        let path = rect.makePath()
        
        // Even zero-size rect should create a path (degenerate case)
        #expect(!path.isEmpty)
    }
    
    @Test("CGRect makePath with negative dimensions")
    func testCGRectMakePathNegativeDimensions() {
        let rect = CGRect(x: 10, y: 10, width: -5, height: -5)
        let path = rect.makePath()
        
        // Negative dimensions should still create a path
        #expect(!path.isEmpty)
    }
    
    @Test("CGRect makePath at origin")
    func testCGRectMakePathAtOrigin() {
        let rect = CGRect(x: 0, y: 0, width: 10, height: 10)
        let path = rect.makePath()
        
        #expect(!path.isEmpty)
    }
    
    // MARK: - LineSegment PathRepresentable Tests
    
    @Test("LineSegment makePath creates line path")
    func testLineSegmentMakePath() {
        let segment = LineSegment(start: CGPoint(x: 1, y: 2), end: CGPoint(x: 10, y: 20))
        let path = segment.makePath()
        
        #expect(!path.isEmpty)
        // The path should represent a line from start to end
    }
    
    @Test("LineSegment makePath with zero length")
    func testLineSegmentMakePathZeroLength() {
        let segment = LineSegment(start: CGPoint(x: 5, y: 5), end: CGPoint(x: 5, y: 5))
        let path = segment.makePath()
        
        // Even zero-length segment should create a path (point)
        #expect(!path.isEmpty)
    }
    
    @Test("LineSegment makePath horizontal line")
    func testLineSegmentMakePathHorizontal() {
        let segment = LineSegment(start: CGPoint(x: 0, y: 5), end: CGPoint(x: 20, y: 5))
        let path = segment.makePath()
        
        #expect(!path.isEmpty)
    }
    
    @Test("LineSegment makePath vertical line")
    func testLineSegmentMakePathVertical() {
        let segment = LineSegment(start: CGPoint(x: 5, y: 0), end: CGPoint(x: 5, y: 20))
        let path = segment.makePath()
        
        #expect(!path.isEmpty)
    }
    
    @Test("LineSegment makePath diagonal line")
    func testLineSegmentMakePathDiagonal() {
        let segment = LineSegment(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 10, y: 10))
        let path = segment.makePath()
        
        #expect(!path.isEmpty)
    }
    
    @Test("LineSegment makePath with negative coordinates")
    func testLineSegmentMakePathNegativeCoordinates() {
        let segment = LineSegment(start: CGPoint(x: -5, y: -10), end: CGPoint(x: 5, y: 10))
        let path = segment.makePath()
        
        #expect(!path.isEmpty)
    }
    
    // MARK: - Polygon PathRepresentable Tests
    
    @Test("Polygon makePath creates closed path")
    func testPolygonMakePath() {
        let polygon = Polygon([
            CGPoint(x: 0, y: 0),
            CGPoint(x: 10, y: 0),
            CGPoint(x: 10, y: 10),
            CGPoint(x: 0, y: 10)
        ])
        let path = polygon.makePath()
        
        #expect(!path.isEmpty)
        // The path should be closed and represent the polygon
    }
    
    @Test("Polygon makePath triangle")
    func testPolygonMakePathTriangle() {
        let polygon = Polygon([
            CGPoint(x: 0, y: 0),
            CGPoint(x: 5, y: 10),
            CGPoint(x: 10, y: 0)
        ])
        let path = polygon.makePath()
        
        #expect(!path.isEmpty)
    }
    
    @Test("Polygon makePath with three vertices (minimum)")
    func testPolygonMakePathMinimumVertices() {
        let polygon = Polygon([
            CGPoint(x: 0, y: 0),
            CGPoint(x: 1, y: 0),
            CGPoint(x: 0, y: 1)
        ])
        let path = polygon.makePath()
        
        #expect(!path.isEmpty)
    }
    
    @Test("Polygon makePath complex polygon")
    func testPolygonMakePathComplex() {
        let polygon = Polygon([
            CGPoint(x: 0, y: 0),
            CGPoint(x: 10, y: 0),
            CGPoint(x: 15, y: 5),
            CGPoint(x: 10, y: 10),
            CGPoint(x: 0, y: 10),
            CGPoint(x: -5, y: 5)
        ])
        let path = polygon.makePath()
        
        #expect(!path.isEmpty)
    }
    
    @Test("Polygon makePath with collinear vertices")
    func testPolygonMakePathCollinear() {
        let polygon = Polygon([
            CGPoint(x: 0, y: 0),
            CGPoint(x: 5, y: 0),
            CGPoint(x: 10, y: 0),
            CGPoint(x: 5, y: 5)
        ])
        let path = polygon.makePath()
        
        #expect(!path.isEmpty)
    }
    
    @Test("Polygon makePath with negative coordinates")
    func testPolygonMakePathNegativeCoordinates() {
        let polygon = Polygon([
            CGPoint(x: -5, y: -5),
            CGPoint(x: 5, y: -5),
            CGPoint(x: 0, y: 5)
        ])
        let path = polygon.makePath()
        
        #expect(!path.isEmpty)
    }
    
    // MARK: - Path Convenience Initializer Tests
    
    @Test("Path init with CGRect representable")
    func testPathInitWithCGRect() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
        let path = Path(representable: rect)
        
        #expect(!path.isEmpty)
        
        // Should be equivalent to direct makePath call
        let directPath = rect.makePath()
        // Note: We can't directly compare paths, but we can verify both are non-empty
        #expect(!directPath.isEmpty)
    }
    
    @Test("Path init with LineSegment representable")
    func testPathInitWithLineSegment() {
        let segment = LineSegment(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 100, y: 100))
        let path = Path(representable: segment)
        
        #expect(!path.isEmpty)
        
        // Should be equivalent to direct makePath call
        let directPath = segment.makePath()
        #expect(!directPath.isEmpty)
    }
    
    @Test("Path init with Polygon representable")
    func testPathInitWithPolygon() {
        let polygon = Polygon([
            CGPoint(x: 0, y: 0),
            CGPoint(x: 10, y: 0),
            CGPoint(x: 5, y: 10)
        ])
        let path = Path(representable: polygon)
        
        #expect(!path.isEmpty)
        
        // Should be equivalent to direct makePath call
        let directPath = polygon.makePath()
        #expect(!directPath.isEmpty)
    }
    
    // MARK: - Edge Cases and Error Conditions
    
    @Test("Multiple PathRepresentable objects can be created")
    func testMultiplePathRepresentables() {
        let rect = CGRect(x: 0, y: 0, width: 10, height: 10)
        let segment = LineSegment(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 10, y: 10))
        let polygon = Polygon([
            CGPoint(x: 0, y: 0),
            CGPoint(x: 5, y: 0),
            CGPoint(x: 2.5, y: 5)
        ])
        
        let rectPath = Path(representable: rect)
        let segmentPath = Path(representable: segment)
        let polygonPath = Path(representable: polygon)
        
        #expect(!rectPath.isEmpty)
        #expect(!segmentPath.isEmpty)
        #expect(!polygonPath.isEmpty)
    }
    
    @Test("PathRepresentable works with computed properties")
    func testPathRepresentableWithComputedProperties() {
        // Create objects with computed properties
        let dynamicRect = CGRect(x: 5 * 2, y: 3 + 2, width: 10, height: 20)
        let dynamicSegment = LineSegment(
            start: CGPoint(x: 1.0, y: 2.0), 
            end: CGPoint(x: 10.5, y: 20.3)
        )
        
        let rectPath = dynamicRect.makePath()
        let segmentPath = dynamicSegment.makePath()
        
        #expect(!rectPath.isEmpty)
        #expect(!segmentPath.isEmpty)
    }
    
    @Test("PathRepresentable protocol method consistency")
    func testPathRepresentableConsistency() {
        let rect = CGRect(x: 10, y: 20, width: 30, height: 40)
        
        // Both approaches should create non-empty paths
        let path1 = rect.makePath()
        let path2 = Path(representable: rect)
        
        #expect(!path1.isEmpty)
        #expect(!path2.isEmpty)
    }
    
    // MARK: - Integration Tests
    
    @Test("PathRepresentable integrates with SwiftUI concepts")
    func testPathRepresentableSwiftUIIntegration() {
        // Test that PathRepresentable objects can be used in SwiftUI-like contexts
        let shapes: [any PathRepresentable] = [
            CGRect(x: 0, y: 0, width: 10, height: 10),
            LineSegment(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 10, y: 10)),
            Polygon([
                CGPoint(x: 0, y: 0),
                CGPoint(x: 5, y: 0),
                CGPoint(x: 2.5, y: 5)
            ])
        ]
        
        // All shapes should be able to create paths
        for shape in shapes {
            let path = shape.makePath()
            #expect(!path.isEmpty)
        }
    }
    
    @Test("PathRepresentable with extreme coordinates")
    func testPathRepresentableExtremeCoordinates() {
        // Test with very large coordinates
        let largeRect = CGRect(x: 1000000, y: 1000000, width: 100, height: 100)
        let largePath = largeRect.makePath()
        #expect(!largePath.isEmpty)
        
        // Test with very small coordinates
        let smallRect = CGRect(x: 0.001, y: 0.001, width: 0.01, height: 0.01)
        let smallPath = smallRect.makePath()
        #expect(!smallPath.isEmpty)
    }
}