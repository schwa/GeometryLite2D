import Testing
import Foundation
import CoreGraphics
@testable import FloorplanSupport

// MARK: - Geometry Tests

@Suite("LineSegment Tests")
struct LineSegmentTests {
    
    @Test("Line segment intersection detection")
    func testIntersection() {
        // Horizontal and vertical lines that intersect
        let horizontal = LineSegment(CGPoint(x: 0, y: 5), CGPoint(x: 10, y: 5))
        let vertical = LineSegment(CGPoint(x: 5, y: 0), CGPoint(x: 5, y: 10))
        
        #expect(horizontal.intersects(vertical))
        #expect(vertical.intersects(horizontal))
        
        let intersection = horizontal.intersection(vertical)
        #expect(intersection != nil)
        #expect(intersection?.x == 5)
        #expect(intersection?.y == 5)
    }
    
    @Test("Line segments that don't intersect")
    func testNoIntersection() {
        let line1 = LineSegment(CGPoint(x: 0, y: 0), CGPoint(x: 5, y: 0))
        let line2 = LineSegment(CGPoint(x: 6, y: 0), CGPoint(x: 10, y: 0))
        
        #expect(!line1.intersects(line2))
        #expect(line1.intersection(line2) == nil)
    }
    
}

@Suite("Polygon Tests")
struct PolygonTests {
    
    @Test("Point in polygon")
    func testContains() {
        // Create a square
        let square = Polygon(vertices: [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 10, y: 0),
            CGPoint(x: 10, y: 10),
            CGPoint(x: 0, y: 10)
        ])
        
        // Points inside
        #expect(square.contains(CGPoint(x: 5, y: 5)))
        #expect(square.contains(CGPoint(x: 1, y: 1)))
        #expect(square.contains(CGPoint(x: 9, y: 9)))
        
        // Points outside
        #expect(!square.contains(CGPoint(x: -1, y: 5)))
        #expect(!square.contains(CGPoint(x: 11, y: 5)))
        #expect(!square.contains(CGPoint(x: 5, y: 11)))
    }
    
    @Test("Polygon area calculation")
    func testArea() {
        // 10x10 square
        let square = Polygon(vertices: [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 10, y: 0),
            CGPoint(x: 10, y: 10),
            CGPoint(x: 0, y: 10)
        ])
        
        #expect(square.area() == 100)
        
        // Triangle with base 10 and height 5
        let triangle = Polygon(vertices: [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 10, y: 0),
            CGPoint(x: 5, y: 5)
        ])
        
        #expect(triangle.area() == 25)
    }
    
    @Test("Segment classification with polygon")
    func testSegmentClassification() {
        let square = Polygon(vertices: [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 10, y: 0),
            CGPoint(x: 10, y: 10),
            CGPoint(x: 0, y: 10)
        ])
        
        // Fully inside
        let inside = LineSegment(CGPoint(x: 2, y: 2), CGPoint(x: 8, y: 8))
        let result1 = square.classify(inside)
        if case .fullyInside = result1 {
            #expect(true)
        } else {
            #expect(false)
        }
        
        // Fully outside
        let outside = LineSegment(CGPoint(x: 15, y: 15), CGPoint(x: 20, y: 20))
        let result2 = square.classify(outside)
        if case .outside = result2 {
            #expect(true)
        } else {
            #expect(false)
        }
        
        // Partially inside (crosses boundary)
        let partial = LineSegment(CGPoint(x: -5, y: 5), CGPoint(x: 15, y: 5))
        let result3 = square.classify(partial)
        if case .partiallyInside(let segments) = result3 {
            #expect(segments.count > 0)
        } else {
            #expect(false)
        }
    }
}