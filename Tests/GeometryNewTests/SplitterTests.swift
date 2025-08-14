import Testing
import Foundation
import CoreGraphics
@testable import FloorplanSupport

@Suite("Splitter Tests")
struct SplitterTests {
    
    @Test("Split two perpendicular segments at intersection")
    func testPerpendicularSegments() {
        // Create a horizontal and vertical segment that intersect at (5, 0)
        let segments: [Identified<String, LineSegment>] = [
            Identified(id: "H", value: LineSegment([0, 0], [10, 0])),  // Horizontal
            Identified(id: "V", value: LineSegment([5, -5], [5, 5]))   // Vertical
        ]
        
        let splits = split(segments: segments)
        
        // Should get 4 segments total (2 from each original segment)
        #expect(splits.count == 4)
        
        // Check that horizontal segment was split into two parts
        let horizontalSplits = splits.filter { $0.id.parent == "H" }
        #expect(horizontalSplits.count == 2)
        
        // Check that vertical segment was split into two parts
        let verticalSplits = splits.filter { $0.id.parent == "V" }
        #expect(verticalSplits.count == 2)
        
        // Verify the split segments have correct endpoints
        let h1 = horizontalSplits.first { $0.id.ordinal == 0 }?.value
        let h2 = horizontalSplits.first { $0.id.ordinal == 1 }?.value
        
        #expect(h1?.start.x == 0)
        #expect(h1?.end.x == 5)
        #expect(h2?.start.x == 5)
        #expect(h2?.end.x == 10)
    }
    
    @Test("T-junction split")
    func testTJunction() {
        // Create a T-junction where vertical segment meets horizontal at its midpoint
        let segments: [Identified<String, LineSegment>] = [
            Identified(id: "H", value: LineSegment([0, 0], [10, 0])),  // Horizontal
            Identified(id: "V", value: LineSegment([5, 0], [5, 5]))    // Vertical starting at horizontal
        ]
        
        let splits = split(segments: segments)
        
        // Horizontal should be split into 2, vertical should remain 1
        #expect(splits.count == 3)
        
        let horizontalSplits = splits.filter { $0.id.parent == "H" }
        #expect(horizontalSplits.count == 2)
        
        let verticalSplits = splits.filter { $0.id.parent == "V" }
        #expect(verticalSplits.count == 1)
    }
    
    @Test("No intersection - parallel segments")
    func testParallelSegments() {
        // Two parallel horizontal segments
        let segments: [Identified<String, LineSegment>] = [
            Identified(id: "H1", value: LineSegment([0, 0], [10, 0])),
            Identified(id: "H2", value: LineSegment([0, 5], [10, 5]))
        ]
        
        let splits = split(segments: segments)
        
        // No intersections, so each segment remains whole
        #expect(splits.count == 2)
        #expect(splits[0].id.ordinal == 0)
        #expect(splits[1].id.ordinal == 0)
    }
    
    @Test("Multiple intersections on single segment")
    func testMultipleIntersections() {
        // One horizontal segment crossed by two verticals
        let segments: [Identified<String, LineSegment>] = [
            Identified(id: "H", value: LineSegment([0, 0], [10, 0])),
            Identified(id: "V1", value: LineSegment([3, -2], [3, 2])),
            Identified(id: "V2", value: LineSegment([7, -2], [7, 2]))
        ]
        
        let splits = split(segments: segments)
        
        // Horizontal should be split into 3 parts
        let horizontalSplits = splits.filter { $0.id.parent == "H" }
        #expect(horizontalSplits.count == 3)
        
        // Each vertical should be split into 2 parts
        let v1Splits = splits.filter { $0.id.parent == "V1" }
        #expect(v1Splits.count == 2)
        
        let v2Splits = splits.filter { $0.id.parent == "V2" }
        #expect(v2Splits.count == 2)
        
        // Total should be 7 segments
        #expect(splits.count == 7)
    }
    
    @Test("Complex intersection - star pattern")
    func testStarPattern() {
        // Four segments meeting at center point (0, 0)
        let segments: [Identified<String, LineSegment>] = [
            Identified(id: "H", value: LineSegment([-5, 0], [5, 0])),   // Horizontal
            Identified(id: "V", value: LineSegment([0, -5], [0, 5])),   // Vertical
            Identified(id: "D1", value: LineSegment([-5, -5], [5, 5])), // Diagonal 1
            Identified(id: "D2", value: LineSegment([-5, 5], [5, -5]))  // Diagonal 2
        ]
        
        let splits = split(segments: segments)
        
        // Each segment should be split into 2 parts (before and after center)
        #expect(splits.count == 8)
        
        // Verify each parent has exactly 2 children
        let parents = Set(splits.map { $0.id.parent })
        for parent in parents {
            let childCount = splits.filter { $0.id.parent == parent }.count
            #expect(childCount == 2)
        }
    }
    
    @Test("Endpoint touching - no split needed")
    func testEndpointTouch() {
        // Two segments that touch at endpoints
        let segments: [Identified<String, LineSegment>] = [
            Identified(id: "S1", value: LineSegment([0, 0], [5, 0])),
            Identified(id: "S2", value: LineSegment([5, 0], [10, 0]))
        ]
        
        let splits = split(segments: segments)
        
        // Segments touch at endpoints but don't cross, so no splitting
        #expect(splits.count == 2)
    }
    
    @Test("Segments with very small epsilon")
    func testEpsilonHandling() {
        // Test that segments very close together are handled properly
        let epsilon: CGFloat = 1e-9
        let segments: [Identified<String, LineSegment>] = [
            Identified(id: "H", value: LineSegment([0, 0], [10, 0])),
            Identified(id: "V1", value: LineSegment([5 - epsilon/2, -5], [5 - epsilon/2, 5])),
            Identified(id: "V2", value: LineSegment([5 + epsilon/2, -5], [5 + epsilon/2, 5]))
        ]
        
        let splits = split(segments: segments, epsilon: epsilon)
        
        // With such small separation, should treat as distinct intersections
        // But with epsilon tolerance, might merge very close points
        #expect(splits.count >= 5) // At least 5 segments expected
    }
    
    @Test("Degenerate segments filtered out")
    func testDegenerateSegments() {
        // Test that zero-length segments are handled
        let segments: [Identified<String, LineSegment>] = [
            Identified(id: "Normal", value: LineSegment([0, 0], [10, 0])),
            Identified(id: "Point", value: LineSegment([5, 5], [5, 5])) // Zero-length
        ]
        
        let splits = split(segments: segments)
        
        // Zero-length segment should not produce output
        let pointSplits = splits.filter { $0.id.parent == "Point" }
        #expect(pointSplits.count == 0)
        
        // Normal segment should remain
        let normalSplits = splits.filter { $0.id.parent == "Normal" }
        #expect(normalSplits.count == 1)
    }
    
    @Test("Split ID stability")
    func testSplitIDStability() {
        // Verify that split IDs are deterministic
        let segments: [Identified<UUID, LineSegment>] = [
            Identified(id: UUID(), value: LineSegment([0, 0], [10, 0])),
            Identified(id: UUID(), value: LineSegment([5, -5], [5, 5]))
        ]
        
        let splits1 = split(segments: segments)
        let splits2 = split(segments: segments)
        
        // Same input should produce same split IDs
        #expect(splits1.count == splits2.count)
        
        for i in 0..<splits1.count {
            #expect(splits1[i].id == splits2[i].id)
            #expect(splits1[i].value == splits2[i].value)
        }
    }
    
    @Test("Grid pattern splitting")
    func testGridPattern() {
        // Create a 2x2 grid
        let segments: [Identified<String, LineSegment>] = [
            // Horizontal lines
            Identified(id: "H1", value: LineSegment([0, 0], [10, 0])),
            Identified(id: "H2", value: LineSegment([0, 5], [10, 5])),
            Identified(id: "H3", value: LineSegment([0, 10], [10, 10])),
            // Vertical lines
            Identified(id: "V1", value: LineSegment([0, 0], [0, 10])),
            Identified(id: "V2", value: LineSegment([5, 0], [5, 10])),
            Identified(id: "V3", value: LineSegment([10, 0], [10, 10]))
        ]
        
        let splits = split(segments: segments)
        
        // Analysis of intersections:
        // H1 (0,0)-(10,0): intersects V1 at (0,0)=endpoint, V2 at (5,0)=interior, V3 at (10,0)=endpoint
        //     → Only V2 causes a split, so 2 parts: (0,0)-(5,0) and (5,0)-(10,0)
        // H2 (0,5)-(10,5): intersects V1 at (0,5)=endpoint, V2 at (5,5)=interior, V3 at (10,5)=endpoint
        //     → Only V2 causes a split, so 2 parts: (0,5)-(5,5) and (5,5)-(10,5)
        // H3 (0,10)-(10,10): intersects V1 at (0,10)=endpoint, V2 at (5,10)=interior, V3 at (10,10)=endpoint
        //     → Only V2 causes a split, so 2 parts: (0,10)-(5,10) and (5,10)-(10,10)
        // V1 (0,0)-(0,10): intersects H1 at (0,0)=endpoint, H2 at (0,5)=interior, H3 at (0,10)=endpoint
        //     → Only H2 causes a split, so 2 parts: (0,0)-(0,5) and (0,5)-(0,10)
        // V2 (5,0)-(5,10): intersects H1 at (5,0)=endpoint, H2 at (5,5)=interior, H3 at (5,10)=endpoint
        //     → Only H2 causes a split, so 2 parts: (5,0)-(5,5) and (5,5)-(5,10)
        // V3 (10,0)-(10,10): intersects H1 at (10,0)=endpoint, H2 at (10,5)=interior, H3 at (10,10)=endpoint
        //     → Only H2 causes a split, so 2 parts: (10,0)-(10,5) and (10,5)-(10,10)
        
        #expect(splits.count == 12) // 6 segments * 2 parts each
        
        // Verify each segment was split correctly
        for id in ["H1", "H2", "H3", "V1", "V2", "V3"] {
            let segmentSplits = splits.filter { $0.id.parent == id }
            #expect(segmentSplits.count == 2, "Segment \(id) should have 2 splits")
        }
    }
}

// Helper to check if two CGPoints are approximately equal
private func pointsEqual(_ p1: CGPoint, _ p2: CGPoint, tolerance: CGFloat = 0.001) -> Bool {
    return abs(p1.x - p2.x) < tolerance && abs(p1.y - p2.y) < tolerance
}
