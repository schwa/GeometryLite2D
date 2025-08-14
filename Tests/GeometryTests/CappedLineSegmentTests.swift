import CoreGraphics
import Foundation // Added to resolve JSONEncoder and JSONDecoder usage
import Geometry
import Testing
struct CappedLineSegmentTests {
    @Test func testInitAndProperties() {
        let start = CGPoint.zero
        let end = CGPoint(x: 1, y: 0)
        let width: CGFloat = 2
        let seg = CappedLineSegment(
            start: start,
            end: end,
            width: width,
            startCap: .butt,
            endCap: .butt
        )
        #expect(seg.start == start)
        #expect(seg.end == end)
        #expect(seg.width == width)
        #expect(seg.startCap == .butt)
        #expect(seg.endCap == .butt)
    }

    @Test func testEdgeCases() {
        // Zero width
        let seg = CappedLineSegment(
            start: CGPoint.zero,
            end: CGPoint(x: 1, y: 0),
            width: 0,
            startCap: .butt,
            endCap: .butt
        )
        #expect(seg.width == 0)
        // Degenerate (start == end)
        let degenerate = CappedLineSegment(
            start: CGPoint(x: 1, y: 1),
            end: CGPoint(x: 1, y: 1),
            width: 1,
            startCap: .butt,
            endCap: .butt
        )
        #expect(degenerate.start == degenerate.end)
    }

    @Test func testVerticesAndPolygon() {
        let seg = CappedLineSegment(
            start: CGPoint.zero,
            end: CGPoint(x: 1, y: 0),
            width: 1,
            startCap: .butt,
            endCap: .butt
        )
        let vertices = seg.vertices
        #expect(vertices.count == 6)
        let polygon = seg.polygon
        #expect(polygon.vertices.count == 6)
    }

    @Test func testMiterCapComputation() {
        let segment = CappedLineSegment(
            start: CGPoint.zero,
            end: CGPoint(x: 1, y: 0),
            width: 1,
            startCap: .butt,
            endCap: .butt
        )
        let points = (CGPoint(x: -0.5, y: 0.5), CGPoint(x: 0, y: 0.5), CGPoint(x: 0.5, y: 0.5))
        let miterCap = segment.computeMiterCap(from: points, for: segment.start)
        #expect(miterCap == .mitered(-0.5, 0, 0.5))
    }

    @Test func testSquareCapVertices() {
        let segment = CappedLineSegment(
            start: CGPoint.zero,
            end: CGPoint(x: 1, y: 0),
            width: 1,
            startCap: .square,
            endCap: .square
        )
        let vertices = segment.vertices
        #expect(vertices.count == 6)
        #expect(vertices[0] == CGPoint(x: -0.5, y: -0.5))
        #expect(vertices[5] == CGPoint(x: 1.5, y: -0.5))
    }

    @Test func testDirectionAndNormal() {
        let segment = CappedLineSegment(
            start: CGPoint.zero,
            end: CGPoint(x: 1, y: 1),
            width: 1,
            startCap: .butt,
            endCap: .butt
        )
        let direction = segment.direction
        let normal = segment.normal
        #expect(abs(direction.dx - 0.7071067811865475) < 0.0001)
        #expect(abs(direction.dy - 0.7071067811865475) < 0.0001)
        #expect(abs(normal.dx - -0.7071067811865475) < 0.0001)
        #expect(abs(normal.dy - 0.7071067811865475) < 0.0001)
    }

    @Test func testPolygonIntegrity() {
        let segment = CappedLineSegment(
            start: CGPoint.zero,
            end: CGPoint(x: 1, y: 0),
            width: 1,
            startCap: .square,
            endCap: .square
        )
        let polygon = segment.polygon
        #expect(polygon.vertices.count == 6)
        #expect(polygon.vertices[0] == CGPoint(x: -0.5, y: -0.5))
        #expect(polygon.vertices[5] == CGPoint(x: 1.5, y: -0.5))
    }

    @Test func testMiteredCaps() {
        let segment = CappedLineSegment(
            start: CGPoint.zero,
            end: CGPoint(x: 1, y: 0),
            width: 1,
            startCap: .mitered(-0.5, 0, 0.5),
            endCap: .mitered(0.5, 0, -0.5)
        )
        let startOffsets = segment.startOffsets
        let endOffsets = segment.endOffsets
        #expect(startOffsets == (-0.5, 0, 0.5))
        #expect(endOffsets == (0.5, 0, -0.5))
    }

    @Test(.disabled())
    func testSetPoint() {
        var segment = CappedLineSegment(
            start: CGPoint.zero,
            end: CGPoint(x: 1, y: 0),
            width: 1,
            startCap: .butt,
            endCap: .butt
        )
        segment.set(point: CGPoint(x: -0.5, y: -0.5), at: 0) // Adjusted Y-coordinate to account for width
        segment.set(point: CGPoint(x: 1.5, y: -0.5), at: 5) // Adjusted Y-coordinate to account for width
        let vertices = segment.vertices
        #expect(vertices[0] == CGPoint(x: -0.5, y: -0.5))
        #expect(vertices[5] == CGPoint(x: 1.5, y: -0.5))
    }

    // Test bevel caps

    @Test(arguments: [(CappedLineSegment, [CGPoint], (CGFloat, CGFloat, CGFloat), (CGFloat, CGFloat, CGFloat))]([
        (
            CappedLineSegment(start: [0, 0], end: [1, 0], width: 0.5, startCap: .butt, endCap: .butt),
            [CGPoint]([[0, -0.25], [0, 0], [0, 0.25], [1, 0.25], [1, 0], [1, -0.25]]),
            (0, 0, 0),
            (0, 0, 0),
            ),
        // Square Caps
        (
            CappedLineSegment(start: [0, 0], end: [1, 0], width: 0.5, startCap: .butt, endCap: .square),
            [CGPoint]([[0, -0.25], [0, 0], [0, 0.25], [1.25, 0.25], [1.25, 0], [1.25, -0.25]]),
            (0, 0, 0),
            (0.25, 0.25, 0.25),
            ),
        (
            CappedLineSegment(start: [0, 0], end: [1, 0], width: 0.5, startCap: .square, endCap: .butt),
            [CGPoint]([[-0.25, -0.25], [-0.25, 0], [-0.25, 0.25], [1, 0.25], [1, 0], [1, -0.25]]),
            (0.25, 0.25, 0.25),
            (0, 0, 0),
            ),
        // TODO: Miter Caps
        // Bevel Caps
        (
            CappedLineSegment(start: [0, 0], end: [1, 0], width: 0.5, startCap: .butt, endCap: .bevel(.first, 0.25)),
            [CGPoint]([[0, -0.25], [0, 0], [0, 0.25], [0.75, 0.25], [1, 0], [1, -0.25]]),
            (0, 0, 0),
            (-0.25, 0, 0),
            ),
        (
            CappedLineSegment(start: [0, 0], end: [1, 0], width: 0.5, startCap: .butt, endCap: .bevel(.second, 0.25)),
            [CGPoint]([[0, -0.25], [0, 0], [0, 0.25], [1, 0.25], [1, 0], [0.75, -0.25]]),
            (0, 0, 0),
            (0, 0, -0.25),
            ),
        (
            CappedLineSegment(start: [0, 0], end: [1, 0], width: 0.5, startCap: .bevel(.first, 0.25), endCap: .butt),
            [CGPoint]([[0.25, -0.25], [0, 0], [0, 0.25], [1, 0.25], [1, 0], [1, -0.25]]),
            (-0.25, 0, 0),
            (0, 0, 0),
            ),
        (
            CappedLineSegment(start: [0, 0], end: [1, 0], width: 0.5, startCap: .bevel(.second, 0.25), endCap: .butt),
            [CGPoint]([[0, -0.25], [0, 0], [0.25, 0.25], [1, 0.25], [1, 0], [1, -0.25]]),
            (0, 0, -0.25),
            (0, 0, 0),
            )
    ]))
    func testVertices(cappedLineSegment: CappedLineSegment, vertices: [CGPoint], startOffsets: (CGFloat, CGFloat, CGFloat), endOffsets: (CGFloat, CGFloat, CGFloat)) {
        // Check vertices
        #expect(cappedLineSegment.vertices == vertices)
        // Check start & end offsets
        #expect(cappedLineSegment.startOffsets == startOffsets)
        #expect(cappedLineSegment.endOffsets == endOffsets)
        var copy = cappedLineSegment
        copy.startOffsets = startOffsets
        #expect(copy == cappedLineSegment)
        copy.endOffsets = endOffsets
        #expect(copy == cappedLineSegment)
    }
}
