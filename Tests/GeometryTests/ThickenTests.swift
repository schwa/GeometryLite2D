import CoreGraphics
@testable import Geometry
import Testing

@Suite("Thicken Algorithm Tests")
struct ThickenTests {
    
    @Test("Thicken single segment")
    func testThickenSingleSegment() {
        let segment = LineSegment(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 10, y: 0))
        let result = thicken(segments: [segment], lineWidth: 2.0)
        
        // With no junctions, returns empty
        #expect(result.count == 0)
    }
    
    @Test("Thicken multiple segments forming junction")
    func testThickenMultipleSegmentsWithJunction() {
        // Create segments that meet at a junction
        let segments = [
            LineSegment(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 5, y: 5)),
            LineSegment(start: CGPoint(x: 5, y: 5), end: CGPoint(x: 10, y: 0)),
            LineSegment(start: CGPoint(x: 5, y: 5), end: CGPoint(x: 5, y: 10))
        ]
        
        let result = thicken(segments: segments, lineWidth: 2.0)
        
        // Should create CappedLineSegments for the junction
        #expect(result.count > 0)
    }
    
    @Test("Thicken removes duplicate segments")
    func testThickenRemovesDuplicates() {
        let segment1 = LineSegment(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 10, y: 0))
        let segment2 = LineSegment(start: CGPoint(x: 10, y: 0), end: CGPoint(x: 0, y: 0)) // Reversed duplicate
        
        let result = thicken(segments: [segment1, segment2], lineWidth: 2.0)
        
        // Should remove duplicates, but with no junction returns empty
        #expect(result.count == 0)
    }
    
    @Test("Thicken junction with single vertex")
    func testThickenJunctionSingleVertex() {
        let junction = Junction(center: CGPoint(x: 5, y: 5), vertices: [CGPoint(x: 10, y: 5)])
        let result = thicken(junction: junction, lineWidth: 2.0, miterLimit: nil)
        
        #expect(result.count == 1)
        #expect(result[0].start == CGPoint(x: 5, y: 5))
        #expect(result[0].end == CGPoint(x: 10, y: 5))
        #expect(result[0].width == 2.0)
    }
    
    @Test("Thicken junction with multiple vertices")
    func testThickenJunctionMultipleVertices() {
        let junction = Junction(
            center: CGPoint(x: 0, y: 0),
            vertices: [
                CGPoint(x: 10, y: 0),  // Right
                CGPoint(x: 0, y: 10),  // Up
                CGPoint(x: -10, y: 0)  // Left
            ]
        )
        
        let result = thicken(junction: junction, lineWidth: 2.0, miterLimit: nil)
        
        #expect(result.count == 3)
        
        // Each segment should start from center
        for segment in result {
            #expect(segment.start == CGPoint(x: 0, y: 0))
            #expect(segment.width == 2.0)
        }
        
        // Check endpoints match vertices
        #expect(result[0].end == CGPoint(x: 10, y: 0))
        #expect(result[1].end == CGPoint(x: 0, y: 10))
        #expect(result[2].end == CGPoint(x: -10, y: 0))
    }
    
    @Test("Thicken T-junction")
    func testThickenTJunction() {
        // T-shaped junction
        let junction = Junction(
            center: CGPoint(x: 5, y: 5),
            vertices: [
                CGPoint(x: 0, y: 5),   // Left
                CGPoint(x: 10, y: 5),  // Right
                CGPoint(x: 5, y: 0)    // Down
            ]
        )
        
        let result = thicken(junction: junction, lineWidth: 2.0, miterLimit: nil)
        
        #expect(result.count == 3)
        
        for segment in result {
            #expect(segment.start == CGPoint(x: 5, y: 5))
            #expect(segment.width == 2.0)
        }
    }
    
    @Test("Thicken cross junction")
    func testThickenCrossJunction() {
        // Cross-shaped junction
        let junction = Junction(
            center: CGPoint(x: 0, y: 0),
            vertices: [
                CGPoint(x: 10, y: 0),   // Right
                CGPoint(x: 0, y: 10),   // Up
                CGPoint(x: -10, y: 0),  // Left
                CGPoint(x: 0, y: -10)   // Down
            ]
        )
        
        let result = thicken(junction: junction, lineWidth: 3.0, miterLimit: nil)
        
        #expect(result.count == 4)
        
        for segment in result {
            #expect(segment.start == CGPoint(x: 0, y: 0))
            #expect(segment.width == 3.0)
        }
    }
    
    @Test("CappedLineSegment set point")
    func testCappedLineSegmentSetPoint() {
        var segment = CappedLineSegment(
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: 10, y: 0),
            width: 2.0
        )
        
        let newPoint = CGPoint(x: 5, y: 5)
        
        // Test setting point at start
        segment.set(point: newPoint, at: 0, endPoint: segment.start)
        
        // Test setting point at end
        segment.set(point: newPoint, at: 0, endPoint: segment.end)
    }
    
    @Test("CappedLineSegment offsets")
    func testCappedLineSegmentOffsets() {
        let segment = CappedLineSegment(
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: 10, y: 0),
            width: 2.0
        )
        
        let startOffsets = segment.offsets(for: segment.start)
        #expect(startOffsets == segment.startOffsets)
        
        let endOffsets = segment.offsets(for: segment.end)
        #expect(endOffsets == segment.endOffsets)
    }
    
    @Test("CappedLineSegment taking caps")
    func testCappedLineSegmentTakingCaps() {
        let segment1 = CappedLineSegment(
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: 10, y: 0),
            width: 2.0,
            startCap: .butt,
            endCap: .square
        )
        
        let segment2 = CappedLineSegment(
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: 10, y: 0),
            width: 2.0,
            startCap: .square,
            endCap: .butt
        )
        
        // Test taking caps when starts match
        let result1 = segment1.takingCaps(from: segment2)
        #expect(result1.startCap == .square) // Should take from segment2 since starts match
        #expect(result1.endCap == .butt) // Keeps the result's endCap from takingCaps logic
        
        // Test taking caps when ends match  
        let segment3 = CappedLineSegment(
            start: CGPoint(x: 5, y: 5),
            end: CGPoint(x: 10, y: 0),
            width: 2.0,
            startCap: .butt,
            endCap: .square
        )
        let result2 = segment1.takingCaps(from: segment3)
        #expect(result2.endCap == segment3.endCap) // Should take from segment3 since ends match
    }
    
    @Test("Thicken with empty segments")
    func testThickenEmptySegments() {
        let result = thicken(segments: [], lineWidth: 2.0)
        #expect(result.isEmpty)
    }
    
    @Test("Thicken junctions with empty junctions list")
    func testThickenEmptyJunctions() {
        let result = thicken(junctions: [], lineWidth: 2.0, miterLimit: nil)
        #expect(result.isEmpty)
    }
    
    @Test("Junction with collinear vertices")
    func testThickenJunctionCollinearVertices() {
        // All vertices in a line
        let junction = Junction(
            center: CGPoint(x: 5, y: 0),
            vertices: [
                CGPoint(x: 0, y: 0),
                CGPoint(x: 10, y: 0)
            ]
        )
        
        let result = thicken(junction: junction, lineWidth: 2.0, miterLimit: nil)
        
        #expect(result.count == 2)
        for segment in result {
            #expect(segment.start == CGPoint(x: 5, y: 0))
            #expect(segment.width == 2.0)
        }
    }
}