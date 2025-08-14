import CoreGraphics
import Geometry
import Testing

struct JunctionTests {
    @Test
    func testInitSortsAndDeduplicatesVertices() {
        let center = CGPoint.zero
        let vertexA = CGPoint(x: 1, y: 0)
        let vertexB = CGPoint(x: 0, y: 1)
        let vertexC = CGPoint(x: -1, y: 0)
        let vertexD = CGPoint(x: 0, y: -1)
        // Intentionally unsorted and with duplicates
        let junction = Junction(center: center, vertices: [vertexC, vertexA, vertexB, vertexA, vertexD, vertexC])
        // Sorted by angle from center
        let expected = [vertexD, vertexA, vertexB, vertexC].sorted { atan2($0.y, $0.x) < atan2($1.y, $1.x) }
        #expect(junction.vertices == expected)
    }

    @Test
    func testSegments() {
        let center = CGPoint.zero
        let vertexA = CGPoint(x: 1, y: 0)
        let vertexB = CGPoint(x: 0, y: 1)
        let junction = Junction(center: center, vertices: [vertexA, vertexB])
        let segments = junction.segments
        #expect(segments.count == 2)
        #expect(segments.contains(LineSegment(start: center, end: vertexA)))
        #expect(segments.contains(LineSegment(start: center, end: vertexB)))
    }

    @Test
    func testEquatable() {
        let center = CGPoint.zero
        let vertexA = CGPoint(x: 1, y: 0)
        let vertexB = CGPoint(x: 0, y: 1)
        let junction1 = Junction(center: center, vertices: [vertexA, vertexB])
        let junction2 = Junction(center: center, vertices: [vertexB, vertexA])
        #expect(junction1 == junction2)
    }

    @Test
    func testFindJunctionsWithSingleSegment() {
        let epsilon: CGFloat = 0.01

        // Define a single line segment
        let segment = LineSegment(start: CGPoint.zero, end: CGPoint(x: 1, y: 1))

        // Call findJunctions
        let junctions = Junction.findJunctions(lineSegments: [segment], absoluteTolerance: epsilon)

        // Validate results
        #expect(junctions.isEmpty)
    }

    @Test
    func testFindJunctionsWithTwoSegmentsSharingVertex() {
        let epsilon: CGFloat = 0.01

        // Define two line segments sharing a common vertex
        let segment1 = LineSegment(start: CGPoint.zero, end: CGPoint(x: 1, y: 1))
        let segment2 = LineSegment(start: CGPoint(x: 1, y: 1), end: CGPoint(x: 2, y: 0))

        // Call findJunctions
        let junctions = Junction.findJunctions(lineSegments: [segment1, segment2], absoluteTolerance: epsilon)

        // Validate results
        #expect(junctions.count == 1)

        // Validate the single junction
        let junction = junctions[0]
        #expect(junction.center == CGPoint(x: 1, y: 1))
        #expect(junction.vertices.contains(CGPoint.zero))
        #expect(junction.vertices.contains(CGPoint(x: 2, y: 0)))
    }

    @Test
    func testFindJunctionsWithTShape() {
        let epsilon: CGFloat = 0.01

        // Define three line segments forming a T-junction
        let segment1 = LineSegment(start: CGPoint.zero, end: CGPoint(x: 1, y: 1))
        let segment2 = LineSegment(start: CGPoint(x: 1, y: 1), end: CGPoint(x: 2, y: 1))
        let segment3 = LineSegment(start: CGPoint(x: 1, y: 1), end: CGPoint(x: 1, y: 2))

        // Call findJunctions
        let junctions = Junction.findJunctions(lineSegments: [segment1, segment2, segment3], absoluteTolerance: epsilon)

        // Validate results
        #expect(junctions.count == 1)

        // Validate the single junction
        let junction = junctions[0]
        #expect(junction.center == CGPoint(x: 1, y: 1))
        #expect(junction.vertices.contains(CGPoint.zero))
        #expect(junction.vertices.contains(CGPoint(x: 2, y: 1)))
        #expect(junction.vertices.contains(CGPoint(x: 1, y: 2)))
    }

    @Test
    func testFindJunctionsWithTriangle() {
        let epsilon: CGFloat = 0.01

        // Define three line segments forming a triangle
        let segment1 = LineSegment(start: [0, 0], end: [1, 1])
        let segment2 = LineSegment(start: [1, 1], end: [2, 0])
        let segment3 = LineSegment(start: [2, 0], end: [0, 0])

        // Call findJunctions
        let junctions = Junction.findJunctions(lineSegments: [segment1, segment2, segment3], absoluteTolerance: epsilon)

        // Validate results
        #expect(junctions.count == 3)

        // Validate each junction
        let junction1 = junctions.first { $0.center == [0, 0] }!
        #expect(junction1.vertices.contains([1, 1]))
        #expect(junction1.vertices.contains([2, 0]))

        let junction2 = junctions.first { $0.center == [1, 1] }!
        #expect(junction2.vertices.contains([0, 0]))
        #expect(junction2.vertices.contains([2, 0]))

        let junction3 = junctions.first { $0.center == [2, 0] }!
        #expect(junction3.vertices.contains([1, 1]))
        #expect(junction3.vertices.contains([0, 0]))
    }

    @Test
    func testFindJunctionsOutputOrderIsStable() {
        let epsilon: CGFloat = 0.01

        // Define line segments forming a triangle
        let segment1 = LineSegment(start: [0, 0], end: [1, 1])
        let segment2 = LineSegment(start: [1, 1], end: [2, 0])
        let segment3 = LineSegment(start: [2, 0], end: [0, 0])

        // Run findJunctions multiple times
        let runs = 100
        var previousOutput: [Junction]? // Removed redundant initialization with nil

        for _ in 0..<runs {
            let junctions = Junction.findJunctions(lineSegments: [segment1, segment2, segment3], absoluteTolerance: epsilon)

            if let previous = previousOutput {
                #expect(junctions == previous, "Output order of junctions is not stable between runs")
            } else {
                previousOutput = junctions
            }
        }
    }
}
