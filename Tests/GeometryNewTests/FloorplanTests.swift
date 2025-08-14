import Testing
import Foundation
import CoreGraphics
@testable import FloorplanSupport

@Suite("Room Detection Tests")
struct RoomDetectionTests {
    
    @Test("Room polygon detection from logged data")
    func testRoomDetection() {
        // Simple test case: A rectangle with an interior wall creating two rooms
        // Layout:
        // (0,0)-----(10,0)-----(20,0)
        //   |         |          |
        //   |   Room1 |   Room2  |
        //   |         |          |
        // (0,10)----(10,10)----(20,10)
        
        let inputSegments = [
            // Top edge (split at x=10)
            LineSegment(CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 0)),
            LineSegment(CGPoint(x: 10, y: 0), CGPoint(x: 20, y: 0)),
            
            // Right edge
            LineSegment(CGPoint(x: 20, y: 0), CGPoint(x: 20, y: 10)),
            
            // Bottom edge (split at x=10)
            LineSegment(CGPoint(x: 20, y: 10), CGPoint(x: 10, y: 10)),
            LineSegment(CGPoint(x: 10, y: 10), CGPoint(x: 0, y: 10)),
            
            // Left edge
            LineSegment(CGPoint(x: 0, y: 10), CGPoint(x: 0, y: 0)),
            
            // Interior wall dividing the space
            LineSegment(CGPoint(x: 10, y: 0), CGPoint(x: 10, y: 10))
        ]
        
        let graph = buildGraph(from: inputSegments)
        
        // Find all cycles in the graph (simulating room detection)
        let allCycles = findAllCycles(in: graph)
        
        // Order vertices and calculate areas for each cycle
        var roomCandidates: [(polygon: Polygon, area: CGFloat)] = []
        for cycle in allCycles {
            guard cycle.count >= 3 else { continue }
            
            // Order vertices by angle from centroid
            let centroid = CGPoint(
                x: cycle.reduce(0) { $0 + $1.x } / CGFloat(cycle.count),
                y: cycle.reduce(0) { $0 + $1.y } / CGFloat(cycle.count)
            )
            let orderedVertices = cycle.sorted { p1, p2 in
                let angle1 = atan2(p1.y - centroid.y, p1.x - centroid.x)
                let angle2 = atan2(p2.y - centroid.y, p2.x - centroid.x)
                return angle1 < angle2
            }
            
            let polygon = Polygon(vertices: orderedVertices)
            let area = polygon.area()
            if area > 0 {
                roomCandidates.append((polygon, area))
            }
        }
        
        // Sort by area and print basic summary
        roomCandidates.sort { $0.area > $1.area }
        
        // Basic test expectations
        #expect(allCycles.count == 2, "Should find exactly 2 unique rooms")
        #expect(roomCandidates.count == 2, "Should have 2 room candidates")
        
        // Verify both rooms have area of 100
        for candidate in roomCandidates {
            #expect(candidate.area == 100.0, "Each room should have area 100")
            #expect(candidate.polygon.vertices.count == 4, "Each room should be a rectangle")
        }
    }
}
