import CoreGraphics
import Geometry
@testable import Thicken
import SwiftUI
import Testing

// MARK: - Test Helpers

extension Array where Element == Path {
    var combinedBounds: CGRect {
        guard let first else { return .zero }
        return dropFirst().reduce(first.boundingRect) { $0.union($1.boundingRect) }
    }

    var allNonEmpty: Bool {
        allSatisfy { !$0.isEmpty }
    }
}

extension Array where Element == Atom {
    var combinedBounds: CGRect {
        map { $0.toPath() }.combinedBounds
    }

    var allNonEmpty: Bool {
        map { $0.toPath() }.allNonEmpty
    }
}

extension Atom {
    var boundingRect: CGRect {
        toPath().boundingRect
    }

    var isEmpty: Bool {
        toPath().isEmpty
    }
}

// MARK: - Single Segment Thickening

@Suite("Single Segment Thickening")
struct SingleSegmentTests {
    let horizontalSegment = LineSegment(start: [0, 0], end: [100, 0])
    let verticalSegment = LineSegment(start: [0, 0], end: [0, 100])
    let diagonalSegment = LineSegment(start: [0, 0], end: [100, 100])
    let width: CGFloat = 20

    @Test("Thickened paths are not empty")
    func thickenedPathNotEmpty() {
        let paths = thickenedSegment(horizontalSegment, width: width)
        #expect(paths.allNonEmpty)
    }

    @Test("Butt cap bounding box matches segment length")
    func buttCapBounds() {
        let paths = thickenedSegment(horizontalSegment, width: width, startCap: .butt, endCap: .butt)
        let bounds = paths.combinedBounds
        #expect(bounds.width.isApproximatelyEqual(to: 100, absoluteTolerance: 0.001))
        #expect(bounds.height.isApproximatelyEqual(to: width, absoluteTolerance: 0.001))
    }

    @Test("Square cap extends by half-width on each end")
    func squareCapBounds() {
        let paths = thickenedSegment(horizontalSegment, width: width, startCap: .square, endCap: .square)
        let bounds = paths.combinedBounds
        #expect(bounds.width.isApproximatelyEqual(to: 120, absoluteTolerance: 0.001))
        #expect(bounds.height.isApproximatelyEqual(to: width, absoluteTolerance: 0.001))
    }

    @Test("Round cap extends by half-width on each end")
    func roundCapBounds() {
        let paths = thickenedSegment(horizontalSegment, width: width, startCap: .round, endCap: .round)
        let bounds = paths.combinedBounds
        #expect(bounds.width.isApproximatelyEqual(to: 120, absoluteTolerance: 0.001))
        #expect(bounds.height.isApproximatelyEqual(to: width, absoluteTolerance: 0.001))
    }

    @Test("Mixed caps: butt start, square end")
    func mixedCapsButtSquare() {
        let paths = thickenedSegment(horizontalSegment, width: width, startCap: .butt, endCap: .square)
        let bounds = paths.combinedBounds
        #expect(bounds.width.isApproximatelyEqual(to: 110, absoluteTolerance: 0.001))
    }

    @Test("Vertical segment thickens correctly")
    func verticalSegmentThickens() {
        let paths = thickenedSegment(verticalSegment, width: width, startCap: .butt, endCap: .butt)
        let bounds = paths.combinedBounds
        #expect(bounds.width.isApproximatelyEqual(to: width, absoluteTolerance: 0.001))
        #expect(bounds.height.isApproximatelyEqual(to: 100, absoluteTolerance: 0.001))
    }

    @Test("Diagonal segment thickens correctly")
    func diagonalSegmentThickens() {
        let paths = thickenedSegment(diagonalSegment, width: width, startCap: .butt, endCap: .butt)
        let bounds = paths.combinedBounds
        #expect(paths.allNonEmpty)
        #expect(bounds.width > 100)
        #expect(bounds.height > 100)
    }

    @Test("Zero-length segment returns small path")
    func zeroLengthSegment() {
        let segment = LineSegment(start: [50, 50], end: [50, 50])
        let paths = thickenedSegment(segment, width: width)
        #expect(paths.combinedBounds.width <= width)
    }

    @Test("Round caps produce multiple paths")
    func roundCapsProduceMultiplePaths() {
        let paths = thickenedSegment(horizontalSegment, width: width, startCap: .round, endCap: .round)
        #expect(paths.count == 3) // body + 2 semicircles
    }

    @Test("Butt caps produce single path")
    func buttCapsProduceSinglePath() {
        let paths = thickenedSegment(horizontalSegment, width: width, startCap: .butt, endCap: .butt)
        #expect(paths.count == 1)
    }
}

// MARK: - Knee-Pit Calculations

@Suite("Knee-Pit Calculations")
struct KneePitTests {
    let width: CGFloat = 20

    @Test("90° right turn knee-pit")
    func rightAngleKneePit() {
        let center = CGPoint(x: 100, y: 100)
        let dir1 = CGVector(dx: 1, dy: 0)
        let dir2 = CGVector(dx: 0, dy: 1)

        let pit = kneePit(center: center, direction1: dir1, direction2: dir2,
                          length1: 100, length2: 100, width: width)

        #expect(pit.distance(to: center) > 0)
        #expect(pit.distance(to: center) < width)
    }

    @Test("90° left turn knee-pit")
    func leftAngleKneePit() {
        let center = CGPoint(x: 100, y: 100)
        let dir1 = CGVector(dx: 1, dy: 0)
        let dir2 = CGVector(dx: 0, dy: -1)

        let pit = kneePit(center: center, direction1: dir1, direction2: dir2,
                          length1: 100, length2: 100, width: width)

        #expect(pit.distance(to: center) > 0)
        #expect(pit.distance(to: center) < width)
    }

    @Test("Very acute angle returns center (bounds exceeded)")
    func acuteAngleKneePit() {
        let center = CGPoint(x: 100, y: 100)
        let dir1 = CGVector(dx: 1, dy: 0)
        let dir2 = CGVector(dx: -0.9, dy: 0.1).normalized

        let pit = kneePit(center: center, direction1: dir1, direction2: dir2,
                          length1: 50, length2: 50, width: width)

        #expect(pit.distance(to: center) < 1)
    }

    @Test("Short segments limit knee-pit distance")
    func shortSegmentKneePit() {
        let center = CGPoint(x: 100, y: 100)
        let dir1 = CGVector(dx: 1, dy: 0)
        let dir2 = CGVector(dx: 0, dy: 1)

        let pit = kneePit(center: center, direction1: dir1, direction2: dir2,
                          length1: 5, length2: 5, width: width)

        #expect(pit.distance(to: center) <= 5)
    }
}

// MARK: - Knee-Cap Generation

@Suite("Knee-Cap Generation")
struct KneeCapTests {
    let width: CGFloat = 20
    let center = CGPoint(x: 100, y: 100)

    @Test("Bevel knee cap is not nil for 90° turn")
    func bevelKneeCapExists() {
        let dir1 = CGVector(dx: 1, dy: 0)
        let dir2 = CGVector(dx: 0, dy: 1)

        let cap = kneeCap(center: center, direction1: dir1, direction2: dir2,
                          length1: 100, length2: 100, width: width, style: .bevel)
        #expect(cap != nil)
    }

    @Test("Round knee cap is not nil for 90° turn")
    func roundKneeCapExists() {
        let dir1 = CGVector(dx: 1, dy: 0)
        let dir2 = CGVector(dx: 0, dy: 1)

        let cap = kneeCap(center: center, direction1: dir1, direction2: dir2,
                          length1: 100, length2: 100, width: width, style: .round)
        #expect(cap != nil)
    }

    @Test("Bevel knee cap bounds are reasonable")
    func bevelKneeCapBounds() {
        let dir1 = CGVector(dx: 1, dy: 0)
        let dir2 = CGVector(dx: 0, dy: 1)

        let cap = kneeCap(center: center, direction1: dir1, direction2: dir2,
                          length1: 100, length2: 100, width: width, style: .bevel)!
        let bounds = cap.boundingRect

        #expect(bounds.width <= width * 2)
        #expect(bounds.height <= width * 2)
    }

    @Test("Round knee cap bounds are reasonable")
    func roundKneeCapBounds() {
        let dir1 = CGVector(dx: 1, dy: 0)
        let dir2 = CGVector(dx: 0, dy: 1)

        let cap = kneeCap(center: center, direction1: dir1, direction2: dir2,
                          length1: 100, length2: 100, width: width, style: .round)!
        let bounds = cap.boundingRect

        #expect(bounds.width <= width * 2)
        #expect(bounds.height <= width * 2)
    }

    @Test("Miter knee cap returns nil")
    func miterKneeCapReturnsNil() {
        let dir1 = CGVector(dx: 1, dy: 0)
        let dir2 = CGVector(dx: 0, dy: 1)

        let cap = kneeCap(center: center, direction1: dir1, direction2: dir2,
                          length1: 100, length2: 100, width: width, style: .miter)
        #expect(cap == nil)
    }
}

// MARK: - Miter Limit

@Suite("Miter Limit")
struct MiterLimitTests {
    let width: CGFloat = 20
    let center = CGPoint(x: 100, y: 100)

    @Test("90° turn does not exceed miter limit")
    func rightAngleWithinLimit() {
        let dir1 = CGVector(dx: 1, dy: 0)
        let dir2 = CGVector(dx: 0, dy: 1)

        let exceeded = miterLimitExceeded(center: center, direction1: dir1, direction2: dir2,
                                          width: width, limit: 4)
        #expect(!exceeded)
    }

    @Test("Very acute angle exceeds miter limit")
    func acuteAngleExceedsLimit() {
        let dir1 = CGVector(dx: 1, dy: 0)
        let dir2 = CGVector(dx: -0.9, dy: 0.2).normalized

        let exceeded = miterLimitExceeded(center: center, direction1: dir1, direction2: dir2,
                                          width: width, limit: 4)
        #expect(exceeded)
    }

    @Test("High limit allows acute angles")
    func highLimitAllowsAcute() {
        let dir1 = CGVector(dx: 1, dy: 0)
        let dir2 = CGVector(dx: -0.5, dy: 0.5).normalized

        let exceeded = miterLimitExceeded(center: center, direction1: dir1, direction2: dir2,
                                          width: width, limit: 100)
        #expect(!exceeded)
    }

    @Test("Low limit triggers on sharper angles")
    func lowLimitTriggersOnSharp() {
        let dir1 = CGVector(dx: 1, dy: 0)
        let dir2 = CGVector(dx: -0.5, dy: 0.866).normalized

        let exceeded = miterLimitExceeded(center: center, direction1: dir1, direction2: dir2,
                                          width: width, limit: 1)
        #expect(exceeded)
    }
}

// MARK: - Two-Segment Joins

@Suite("Two-Segment Joins")
struct TwoSegmentJoinTests {
    let width: CGFloat = 20

    @Test("90° elbow with miter join")
    func elbowMiterJoin() {
        let seg1 = LineSegment(start: [0, 100], end: [100, 100])
        let seg2 = LineSegment(start: [100, 100], end: [100, 200])

        let joint = JointEnd(otherDirection: seg1.direction, otherLength: seg1.length, joinStyle: .miter)
        let paths = thickenedSegment(seg2, width: width, startJoint: joint)

        #expect(paths.allNonEmpty)
    }

    @Test("90° elbow with bevel join")
    func elbowBevelJoin() {
        let seg1 = LineSegment(start: [0, 100], end: [100, 100])
        let seg2 = LineSegment(start: [100, 100], end: [100, 200])

        let joint = JointEnd(otherDirection: seg1.direction, otherLength: seg1.length, joinStyle: .bevel)
        let paths = thickenedSegment(seg2, width: width, startJoint: joint)

        #expect(paths.allNonEmpty)
    }

    @Test("90° elbow with round join")
    func elbowRoundJoin() {
        let seg1 = LineSegment(start: [0, 100], end: [100, 100])
        let seg2 = LineSegment(start: [100, 100], end: [100, 200])

        let joint = JointEnd(otherDirection: seg1.direction, otherLength: seg1.length, joinStyle: .round)
        let paths = thickenedSegment(seg2, width: width, startJoint: joint)

        #expect(paths.allNonEmpty)
    }

    @Test("Acute angle join doesn't spike")
    func acuteAngleNoSpike() {
        let seg1 = LineSegment(start: [0, 100], end: [100, 100])
        let seg2 = LineSegment(start: [100, 100], end: [50, 120])

        let joint = JointEnd(otherDirection: seg1.direction, otherLength: seg1.length, joinStyle: .miter)
        let paths = thickenedSegment(seg2, width: width, startJoint: joint)
        let bounds = paths.combinedBounds

        #expect(bounds.width < 200)
        #expect(bounds.height < 200)
    }
}

// MARK: - Polyline

@Suite("Polyline")
struct PolylineTests {
    let width: CGFloat = 20

    @Test("2-point polyline produces paths")
    func twoPointPolyline() {
        let paths = Polyline(vertices: [[0, 0], [100, 0]]).thickened(width: width)
        #expect(paths.count >= 1)
    }

    @Test("3-point polyline produces paths")
    func threePointPolyline() {
        let paths = Polyline(vertices: [[0, 0], [100, 0], [100, 100]]).thickened(width: width)
        #expect(paths.count >= 2)
    }

    @Test("Polyline paths are not empty")
    func polylinePathsNotEmpty() {
        let paths = Polyline(vertices: [[0, 0], [100, 0], [100, 100]]).thickened(width: width)
        for path in paths {
            #expect(!path.isEmpty)
        }
    }

    @Test("Polyline with bevel join")
    func polylineBevel() {
        let paths = Polyline(vertices: [[0, 0], [100, 0], [100, 100]]).thickened(width: width, joinStyle: .bevel)
        #expect(paths.count >= 2)
    }

    @Test("Polyline with round join")
    func polylineRound() {
        let paths = Polyline(vertices: [[0, 0], [100, 0], [100, 100]]).thickened(width: width, joinStyle: .round)
        #expect(paths.count >= 2)
    }
}

// MARK: - N-Way Junctions

@Suite("N-Way Junctions")
struct JunctionTests {
    let width: CGFloat = 30
    let center = CGPoint(x: 200, y: 200)

    @Test("2-way junction produces paths")
    func twoWayJunction() {
        let endpoints: [CGPoint] = [[100, 200], [300, 200]]
        let paths = Junction(center: center, vertices: endpoints).thickened(width: width)
        #expect(paths.count >= 2)
    }

    @Test("3-way junction produces paths")
    func threeWayJunction() {
        let endpoints: [CGPoint] = [[100, 200], [300, 200], [200, 320]]
        let paths = Junction(center: center, vertices: endpoints).thickened(width: width)
        #expect(paths.count >= 3)
    }

    @Test("4-way junction produces paths")
    func fourWayJunction() {
        let endpoints: [CGPoint] = [[100, 200], [300, 200], [200, 100], [200, 300]]
        let paths = Junction(center: center, vertices: endpoints).thickened(width: width)
        #expect(paths.count >= 4)
    }

    @Test("Junction paths are not empty")
    func junctionPathsNotEmpty() {
        let endpoints: [CGPoint] = [[100, 200], [300, 200], [200, 320]]
        let paths = Junction(center: center, vertices: endpoints).thickened(width: width)
        for path in paths {
            #expect(!path.isEmpty)
        }
    }

    @Test("Junction with bevel")
    func junctionBevel() {
        let endpoints: [CGPoint] = [[100, 200], [300, 200], [200, 320]]
        let paths = Junction(center: center, vertices: endpoints).thickened(width: width, joinStyle: .bevel)
        #expect(paths.count >= 3)
    }

    @Test("Junction with round")
    func junctionRound() {
        let endpoints: [CGPoint] = [[100, 200], [300, 200], [200, 320]]
        let paths = Junction(center: center, vertices: endpoints).thickened(width: width, joinStyle: .round)
        #expect(paths.count >= 3)
    }

    @Test("Cross junction (4-way)")
    func crossJunction() {
        let endpoints: [CGPoint] = [[100, 200], [300, 200], [200, 100], [200, 300]]
        let paths = Junction(center: center, vertices: endpoints).thickened(width: width, joinStyle: .bevel)
        #expect(paths.count == 4)  // No knee caps for perfect cross
    }

    @Test("Y-junction (120° each)")
    func yJunction() {
        let angle1 = 0.0
        let angle2 = 2 * Double.pi / 3
        let angle3 = 4 * Double.pi / 3
        let r: CGFloat = 100
        let endpoints: [CGPoint] = [
            CGPoint(x: center.x + r * cos(angle1), y: center.y + r * sin(angle1)),
            CGPoint(x: center.x + r * cos(angle2), y: center.y + r * sin(angle2)),
            CGPoint(x: center.x + r * cos(angle3), y: center.y + r * sin(angle3))
        ]
        let paths = Junction(center: center, vertices: endpoints).thickened(width: width, joinStyle: .bevel)
        #expect(paths.count == 3)  // No knee caps for 120° gaps
    }
}

// MARK: - Junction End Caps

@Suite("Junction End Caps")
struct JunctionCapTests {
    let width: CGFloat = 30
    let center = CGPoint(x: 200, y: 200)

    @Test("Junction with butt caps")
    func junctionButtCaps() {
        let endpoints: [CGPoint] = [[100, 200], [300, 200], [200, 320]]
        let paths = Junction(center: center, vertices: endpoints).thickened(width: width, capStyle: .butt)
        #expect(paths.count >= 3)
    }

    @Test("Junction with square caps")
    func junctionSquareCaps() {
        let endpoints: [CGPoint] = [[100, 200], [300, 200]]
        let paths = Junction(center: center, vertices: endpoints).thickened(width: width, capStyle: .square)
        #expect(paths.count >= 2)
    }

    @Test("Junction with round caps")
    func junctionRoundCaps() {
        let endpoints: [CGPoint] = [[100, 200], [300, 200], [200, 320]]
        let paths = Junction(center: center, vertices: endpoints).thickened(width: width, capStyle: .round)
        #expect(paths.count >= 3)
    }
}

// MARK: - Junction Miter Limit

@Suite("Junction Miter Limit")
struct JunctionMiterLimitTests {
    let width: CGFloat = 30
    let center = CGPoint(x: 200, y: 200)

    @Test("Junction miter with high limit")
    func junctionMiterHighLimit() {
        let endpoints: [CGPoint] = [[100, 200], [300, 200], [200, 300]]
        let paths = Junction(center: center, vertices: endpoints).thickened(width: width,
                             joinStyle: .miter(limit: 100))
        #expect(paths.count >= 3)
    }

    @Test("Junction miter with low limit")
    func junctionMiterLowLimit() {
        let endpoints: [CGPoint] = [[100, 200], [300, 200], [200, 250]]
        let paths = Junction(center: center, vertices: endpoints).thickened(width: width,
                             joinStyle: .miter(limit: 1))
        #expect(paths.count >= 3)
    }
}

// MARK: - Edge Cases

@Suite("Edge Cases")
struct EdgeCaseTests {
    let width: CGFloat = 20

    @Test("Very short segment thickens")
    func veryShortSegment() {
        let segment = LineSegment(start: [0, 0], end: [1, 0])
        let paths = thickenedSegment(segment, width: width)
        #expect(paths.allNonEmpty)
    }

    @Test("Very long segment thickens")
    func veryLongSegment() {
        let segment = LineSegment(start: [0, 0], end: [10_000, 0])
        let paths = thickenedSegment(segment, width: width)
        #expect(paths.allNonEmpty)
        #expect(paths.combinedBounds.width.isApproximatelyEqual(to: 10_000, absoluteTolerance: 1))
    }

    @Test("Very wide stroke")
    func veryWideStroke() {
        let segment = LineSegment(start: [0, 0], end: [100, 0])
        let paths = thickenedSegment(segment, width: 200)
        #expect(paths.allNonEmpty)
        #expect(paths.combinedBounds.height.isApproximatelyEqual(to: 200, absoluteTolerance: 1))
    }

    @Test("Very narrow stroke")
    func veryNarrowStroke() {
        let segment = LineSegment(start: [0, 0], end: [100, 0])
        let paths = thickenedSegment(segment, width: 0.1)
        #expect(paths.allNonEmpty)
    }

    @Test("Single point junction")
    func singlePointJunction() {
        let center = CGPoint(x: 100, y: 100)
        let endpoints: [CGPoint] = [[150, 100]]
        let paths = Junction(center: center, vertices: endpoints).thickened(width: width)
        #expect(paths.count >= 1)
    }

    @Test("Collinear segments (180° turn)")
    func collinearSegments() {
        let seg1 = LineSegment(start: [0, 100], end: [100, 100])
        let seg2 = LineSegment(start: [100, 100], end: [200, 100])

        let joint = JointEnd(otherDirection: seg1.direction, otherLength: seg1.length, joinStyle: .miter)
        let paths = thickenedSegment(seg2, width: width, startJoint: joint)

        #expect(paths.allNonEmpty)
    }

    @Test("Empty polyline")
    func emptyPolyline() {
        let paths = Polyline(vertices: []).thickened(width: width)
        #expect(paths.isEmpty)
    }

    @Test("Single point polyline")
    func singlePointPolyline() {
        let paths = Polyline(vertices: [[100, 100]]).thickened(width: width)
        #expect(paths.isEmpty)
    }
}

// MARK: - Atom Tests

@Suite("Atom")
struct AtomTests {
    @Test("Polygon with 4 vertices")
    func polygonPath() {
        let atom = Atom.polygon(vertices: [[0, 0], [100, 0], [100, 50], [0, 50]])
        let path = atom.toPath()
        #expect(!path.isEmpty)
        #expect(path.boundingRect.width.isApproximatelyEqual(to: 100, absoluteTolerance: 0.001))
        #expect(path.boundingRect.height.isApproximatelyEqual(to: 50, absoluteTolerance: 0.001))
    }

    @Test("Wedge (triangle)")
    func wedgePath() {
        let atom = Atom.wedge(apex: [50, 0], p0: [0, 100], p2: [100, 100])
        let path = atom.toPath()
        #expect(!path.isEmpty)
        #expect(path.contains(CGPoint(x: 50, y: 50)))
    }

    @Test("Pieslice")
    func pieslicePath() {
        let center = CGPoint(x: 50, y: 50)
        let atom = Atom.pieslice(apex: center, arcCenter: center, p0: [100, 50], p2: [50, 100], clockwise: true)
        let path = atom.toPath()
        #expect(!path.isEmpty)
        #expect(path.contains(center))
    }

    @Test("Empty polygon")
    func emptyPolygon() {
        let atom = Atom.polygon(vertices: [])
        let path = atom.toPath()
        #expect(path.isEmpty)
    }
}

// MARK: - Helpers

extension CGFloat {
    func isApproximatelyEqual(to other: CGFloat, absoluteTolerance: CGFloat) -> Bool {
        abs(self - other) <= absoluteTolerance
    }
}

extension CGVector {
    var normalized: CGVector {
        let len = sqrt(dx * dx + dy * dy)
        return CGVector(dx: dx / len, dy: dy / len)
    }
}

extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        sqrt(pow(x - other.x, 2) + pow(y - other.y, 2))
    }
}
