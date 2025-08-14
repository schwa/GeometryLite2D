import CoreGraphics
import Geometry
import Testing

@Suite("SegmentIntersection Tests")
struct SegmentIntersectionTests {
    
    @Test("Basic intersection - two segments crossing")
    func testBasicIntersection() {
        let s1 = LineSegment(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 10, y: 10))
        let s2 = LineSegment(start: CGPoint(x: 0, y: 10), end: CGPoint(x: 10, y: 0))
        
        let result = s1.segmentIntersection(with: s2)
        
        switch result {
        case let .point(p, t1, t2):
            #expect(p.isApproximatelyEqual(to: CGPoint(x: 5, y: 5), absoluteTolerance: 1e-10))
            #expect(t1.isApproximatelyEqual(to: 0.5, absoluteTolerance: 1e-10))
            #expect(t2.isApproximatelyEqual(to: 0.5, absoluteTolerance: 1e-10))
        case .none:
            Issue.record("Expected intersection point but got none")
        }
    }
    
    @Test("No intersection - parallel segments")
    func testParallelSegments() {
        let s1 = LineSegment(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 10, y: 0))
        let s2 = LineSegment(start: CGPoint(x: 0, y: 1), end: CGPoint(x: 10, y: 1))
        
        let result = s1.segmentIntersection(with: s2)
        
        switch result {
        case .none:
            // Expected
            break
        case .point:
            Issue.record("Expected no intersection for parallel segments")
        }
    }
    
    @Test("No intersection - segments don't reach each other")
    func testNonIntersectingSegments() {
        let s1 = LineSegment(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 5, y: 0))
        let s2 = LineSegment(start: CGPoint(x: 6, y: -1), end: CGPoint(x: 6, y: 1))
        
        let result = s1.segmentIntersection(with: s2)
        
        switch result {
        case .none:
            // Expected
            break
        case .point:
            Issue.record("Expected no intersection for non-reaching segments")
        }
    }
    
    @Test("Intersection at endpoint")
    func testEndpointIntersection() {
        let s1 = LineSegment(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 10, y: 0))
        let s2 = LineSegment(start: CGPoint(x: 10, y: 0), end: CGPoint(x: 10, y: 10))
        
        let result = s1.segmentIntersection(with: s2)
        
        switch result {
        case let .point(p, t1, t2):
            #expect(p.isApproximatelyEqual(to: CGPoint(x: 10, y: 0), absoluteTolerance: 1e-10))
            #expect(t1.isApproximatelyEqual(to: 1.0, absoluteTolerance: 1e-10))
            #expect(t2.isApproximatelyEqual(to: 0.0, absoluteTolerance: 1e-10))
        case .none:
            Issue.record("Expected intersection at endpoint")
        }
    }
    
    @Test("T-intersection")
    func testTIntersection() {
        let s1 = LineSegment(start: CGPoint(x: 0, y: 5), end: CGPoint(x: 10, y: 5))
        let s2 = LineSegment(start: CGPoint(x: 5, y: 0), end: CGPoint(x: 5, y: 10))
        
        let result = s1.segmentIntersection(with: s2)
        
        switch result {
        case let .point(p, t1, t2):
            #expect(p.isApproximatelyEqual(to: CGPoint(x: 5, y: 5), absoluteTolerance: 1e-10))
            #expect(t1.isApproximatelyEqual(to: 0.5, absoluteTolerance: 1e-10))
            #expect(t2.isApproximatelyEqual(to: 0.5, absoluteTolerance: 1e-10))
        case .none:
            Issue.record("Expected T-intersection")
        }
    }
    
    @Test("Collinear segments (currently returns .none)")
    func testCollinearSegments() {
        let s1 = LineSegment(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 10, y: 0))
        let s2 = LineSegment(start: CGPoint(x: 5, y: 0), end: CGPoint(x: 15, y: 0))
        
        let result = s1.segmentIntersection(with: s2)
        
        // Current implementation returns .none for collinear segments
        switch result {
        case .none:
            // Expected with current implementation
            break
        case .point:
            Issue.record("Unexpected point intersection for collinear segments")
        }
    }
    
    @Test("Segments with different slopes")
    func testDifferentSlopes() {
        let s1 = LineSegment(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 10, y: 5))
        let s2 = LineSegment(start: CGPoint(x: 0, y: 5), end: CGPoint(x: 10, y: 0))
        
        let result = s1.segmentIntersection(with: s2)
        
        switch result {
        case let .point(p, t1, t2):
            // Calculate expected intersection point
            // Line 1: y = 0.5x
            // Line 2: y = 5 - 0.5x
            // Intersection: 0.5x = 5 - 0.5x => x = 5, y = 2.5
            #expect(p.isApproximatelyEqual(to: CGPoint(x: 5, y: 2.5), absoluteTolerance: 1e-10))
            #expect(t1.isApproximatelyEqual(to: 0.5, absoluteTolerance: 1e-10))
            #expect(t2.isApproximatelyEqual(to: 0.5, absoluteTolerance: 1e-10))
        case .none:
            Issue.record("Expected intersection for segments with different slopes")
        }
    }
    
    @Test("Vertical and horizontal segments")
    func testVerticalHorizontalIntersection() {
        let horizontal = LineSegment(start: CGPoint(x: -5, y: 3), end: CGPoint(x: 5, y: 3))
        let vertical = LineSegment(start: CGPoint(x: 2, y: -5), end: CGPoint(x: 2, y: 5))
        
        let result = horizontal.segmentIntersection(with: vertical)
        
        switch result {
        case let .point(p, t1, t2):
            #expect(p.isApproximatelyEqual(to: CGPoint(x: 2, y: 3), absoluteTolerance: 1e-10))
            #expect(t1.isApproximatelyEqual(to: 0.7, absoluteTolerance: 1e-10)) // (2 - (-5)) / 10 = 0.7
            #expect(t2.isApproximatelyEqual(to: 0.8, absoluteTolerance: 1e-10)) // (3 - (-5)) / 10 = 0.8
        case .none:
            Issue.record("Expected intersection for vertical and horizontal segments")
        }
    }
    
    @Test("Nearly parallel segments with tolerance")
    func testNearlyParallelSegments() {
        let s1 = LineSegment(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 10, y: 0))
        let s2 = LineSegment(start: CGPoint(x: 0, y: 0.0000000001), end: CGPoint(x: 10, y: 0.0000000001))
        
        let result = s1.segmentIntersection(with: s2, absoluteTolerance: 1e-9)
        
        switch result {
        case .none:
            // Expected - they're parallel within tolerance
            break
        case .point:
            Issue.record("Expected no intersection for nearly parallel segments")
        }
    }
    
    @Test("Intersection method returns only point")
    func testIntersectionMethod() {
        let s1 = LineSegment(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 10, y: 10))
        let s2 = LineSegment(start: CGPoint(x: 0, y: 10), end: CGPoint(x: 10, y: 0))
        
        let point = s1.intersection(s2)
        
        #expect(point != nil)
        if let point = point {
            #expect(point.isApproximatelyEqual(to: CGPoint(x: 5, y: 5), absoluteTolerance: 1e-10))
        }
    }
    
    @Test("Intersection method returns nil for no intersection")
    func testIntersectionMethodNoIntersection() {
        let s1 = LineSegment(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 10, y: 0))
        let s2 = LineSegment(start: CGPoint(x: 0, y: 1), end: CGPoint(x: 10, y: 1))
        
        let point = s1.intersection(s2)
        
        #expect(point == nil)
    }
}