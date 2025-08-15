import CoreGraphics
@testable import Geometry
import Testing

@Suite("CGPoint+Comparator Tests")
struct CGPointComparatorTests {
    // MARK: - XThenY Comparator Tests

    @Test("XThenY comparator - different x coordinates")
    func testXThenYDifferentX() {
        let point1 = CGPoint(x: 1, y: 5)
        let point2 = CGPoint(x: 3, y: 5)

        let result = point1.compare(to: point2, using: .xThenY)
        #expect(result == .orderedAscending)

        let reverseResult = point2.compare(to: point1, using: .xThenY)
        #expect(reverseResult == .orderedDescending)
    }

    @Test("XThenY comparator - same x, different y coordinates")
    func testXThenYSameXDifferentY() {
        let point1 = CGPoint(x: 5, y: 1)
        let point2 = CGPoint(x: 5, y: 3)

        let result = point1.compare(to: point2, using: .xThenY)
        #expect(result == .orderedAscending)

        let reverseResult = point2.compare(to: point1, using: .xThenY)
        #expect(reverseResult == .orderedDescending)
    }

    @Test("XThenY comparator - identical points")
    func testXThenYIdenticalPoints() {
        let point1 = CGPoint(x: 5, y: 5)
        let point2 = CGPoint(x: 5, y: 5)

        let result = point1.compare(to: point2, using: .xThenY)
        #expect(result == .orderedSame)
    }

    @Test("XThenY comparator - x takes precedence over y")
    func testXThenYPrecedence() {
        let point1 = CGPoint(x: 1, y: 10)  // Lower x, higher y
        let point2 = CGPoint(x: 2, y: 1)   // Higher x, lower y

        let result = point1.compare(to: point2, using: .xThenY)
        #expect(result == .orderedAscending) // x takes precedence
    }

    @Test("XThenY comparator - with negative coordinates")
    func testXThenYNegativeCoordinates() {
        let point1 = CGPoint(x: -5, y: -3)
        let point2 = CGPoint(x: -2, y: -8)

        let result = point1.compare(to: point2, using: .xThenY)
        #expect(result == .orderedAscending) // -5 < -2
    }

    @Test("XThenY comparator - with zero coordinates")
    func testXThenYZeroCoordinates() {
        let point1 = CGPoint.zero
        let point2 = CGPoint(x: 1, y: 0)

        let result = point1.compare(to: point2, using: .xThenY)
        #expect(result == .orderedAscending)
    }

    // MARK: - YThenX Comparator Tests

    @Test("YThenX comparator - different y coordinates")
    func testYThenXDifferentY() {
        let point1 = CGPoint(x: 5, y: 1)
        let point2 = CGPoint(x: 5, y: 3)

        let result = point1.compare(to: point2, using: .yThenX)
        #expect(result == .orderedAscending)

        let reverseResult = point2.compare(to: point1, using: .yThenX)
        #expect(reverseResult == .orderedDescending)
    }

    @Test("YThenX comparator - same y, different x coordinates")
    func testYThenXSameYDifferentX() {
        let point1 = CGPoint(x: 1, y: 5)
        let point2 = CGPoint(x: 3, y: 5)

        let result = point1.compare(to: point2, using: .yThenX)
        #expect(result == .orderedAscending)

        let reverseResult = point2.compare(to: point1, using: .yThenX)
        #expect(reverseResult == .orderedDescending)
    }

    @Test("YThenX comparator - identical points")
    func testYThenXIdenticalPoints() {
        let point1 = CGPoint(x: 5, y: 5)
        let point2 = CGPoint(x: 5, y: 5)

        let result = point1.compare(to: point2, using: .yThenX)
        #expect(result == .orderedSame)
    }

    @Test("YThenX comparator - y takes precedence over x")
    func testYThenXPrecedence() {
        let point1 = CGPoint(x: 10, y: 1)  // Higher x, lower y
        let point2 = CGPoint(x: 1, y: 2)   // Lower x, higher y

        let result = point1.compare(to: point2, using: .yThenX)
        #expect(result == .orderedAscending) // y takes precedence
    }

    @Test("YThenX comparator - with negative coordinates")
    func testYThenXNegativeCoordinates() {
        let point1 = CGPoint(x: -3, y: -5)
        let point2 = CGPoint(x: -8, y: -2)

        let result = point1.compare(to: point2, using: .yThenX)
        #expect(result == .orderedAscending) // -5 < -2
    }

    // MARK: - RelativeAngleFrom Comparator Tests

    @Test("RelativeAngleFrom comparator - different angles from origin")
    func testRelativeAngleFromOrigin() {
        let center = CGPoint.zero
        let point1 = CGPoint(x: 1, y: 0)    // 0 degrees
        let point2 = CGPoint(x: 0, y: 1)    // 90 degrees

        let result = point1.compare(to: point2, using: .relativeAngleFrom(center))
        #expect(result == .orderedAscending) // 0 < 90 degrees
    }

    @Test("RelativeAngleFrom comparator - same angle from center")
    func testRelativeAngleFromSameAngle() {
        let center = CGPoint.zero
        let point1 = CGPoint(x: 1, y: 1)    // 45 degrees
        let point2 = CGPoint(x: 2, y: 2)    // 45 degrees

        let result = point1.compare(to: point2, using: .relativeAngleFrom(center))
        #expect(result == .orderedSame)
    }

    @Test("RelativeAngleFrom comparator - with non-origin center")
    func testRelativeAngleFromNonOriginCenter() {
        let center = CGPoint(x: 5, y: 5)
        let point1 = CGPoint(x: 6, y: 5)    // 0 degrees relative to center
        let point2 = CGPoint(x: 5, y: 6)    // 90 degrees relative to center

        let result = point1.compare(to: point2, using: .relativeAngleFrom(center))
        #expect(result == .orderedAscending)
    }

    @Test("RelativeAngleFrom comparator - negative angles")
    func testRelativeAngleFromNegativeAngles() {
        let center = CGPoint.zero
        let point1 = CGPoint(x: 1, y: -1)   // -45 degrees
        let point2 = CGPoint(x: 1, y: 1)    // 45 degrees

        let result = point1.compare(to: point2, using: .relativeAngleFrom(center))
        #expect(result == .orderedAscending) // -45 < 45 degrees
    }

    @Test("RelativeAngleFrom comparator - full circle")
    func testRelativeAngleFromFullCircle() {
        let center = CGPoint.zero
        let point1 = CGPoint(x: 1, y: 0)     // 0 degrees
        let point2 = CGPoint(x: -1, y: 0)    // 180 degrees (π)
        let point3 = CGPoint(x: 0, y: -1)    // -90 degrees (-π/2)

        let result1 = point1.compare(to: point2, using: .relativeAngleFrom(center))
        #expect(result1 == .orderedAscending) // 0 < π

        let result2 = point3.compare(to: point1, using: .relativeAngleFrom(center))
        #expect(result2 == .orderedAscending) // -π/2 < 0
    }

    @Test("RelativeAngleFrom comparator - point at center")
    func testRelativeAngleFromPointAtCenter() {
        let center = CGPoint(x: 5, y: 5)
        let point1 = CGPoint(x: 5, y: 5)    // At center (angle is 0)
        let point2 = CGPoint(x: 6, y: 5)    // 0 degrees from center

        // When point is at center, atan2(0,0) = 0, same as horizontal point
        let result = point1.compare(to: point2, using: .relativeAngleFrom(center))
        #expect(result == .orderedSame) // Both have angle 0
    }

    // MARK: - DistanceFrom Comparator Tests

    @Test("DistanceFrom comparator - different distances from origin")
    func testDistanceFromOrigin() {
        let origin = CGPoint.zero
        let point1 = CGPoint(x: 3, y: 0)    // Distance 3
        let point2 = CGPoint(x: 0, y: 4)    // Distance 4

        let result = point1.compare(to: point2, using: .distanceFrom(origin))
        #expect(result == .orderedAscending) // 3 < 4
    }

    @Test("DistanceFrom comparator - same distance from origin")
    func testDistanceFromSameDistance() {
        let origin = CGPoint.zero
        let point1 = CGPoint(x: 3, y: 4)    // Distance 5
        let point2 = CGPoint(x: 4, y: 3)    // Distance 5

        let result = point1.compare(to: point2, using: .distanceFrom(origin))
        #expect(result == .orderedSame)
    }

    @Test("DistanceFrom comparator - with non-origin reference")
    func testDistanceFromNonOrigin() {
        let reference = CGPoint(x: 5, y: 5)
        let point1 = CGPoint(x: 6, y: 5)    // Distance 1
        let point2 = CGPoint(x: 8, y: 5)    // Distance 3

        let result = point1.compare(to: point2, using: .distanceFrom(reference))
        #expect(result == .orderedAscending) // 1 < 3
    }

    @Test("DistanceFrom comparator - zero distance")
    func testDistanceFromZeroDistance() {
        let reference = CGPoint(x: 5, y: 5)
        let point1 = CGPoint(x: 5, y: 5)    // Distance 0 (same as reference)
        let point2 = CGPoint(x: 6, y: 5)    // Distance 1

        let result = point1.compare(to: point2, using: .distanceFrom(reference))
        #expect(result == .orderedAscending) // 0 < 1
    }

    @Test("DistanceFrom comparator - negative coordinates")
    func testDistanceFromNegativeCoordinates() {
        let reference = CGPoint.zero
        let point1 = CGPoint(x: -3, y: 0)   // Distance 3
        let point2 = CGPoint(x: 0, y: -5)   // Distance 5

        let result = point1.compare(to: point2, using: .distanceFrom(reference))
        #expect(result == .orderedAscending) // 3 < 5
    }

    @Test("DistanceFrom comparator - Pythagorean theorem")
    func testDistanceFromPythagorean() {
        let reference = CGPoint.zero
        let point1 = CGPoint(x: 3, y: 4)    // Distance 5 (3-4-5 triangle)
        let point2 = CGPoint(x: 5, y: 12)   // Distance 13 (5-12-13 triangle)

        let result = point1.compare(to: point2, using: .distanceFrom(reference))
        #expect(result == .orderedAscending) // 5 < 13
    }

    // MARK: - Comparator Consistency Tests

    @Test("Comparator reflexivity - point compared to itself")
    func testComparatorReflexivity() {
        let point = CGPoint(x: 5, y: 3)
        let comparators: [CGPoint.Comparator] = [
            .xThenY,
            .yThenX,
            .relativeAngleFrom(CGPoint.zero),
            .distanceFrom(CGPoint(x: 1, y: 1))
        ]

        for comparator in comparators {
            let result = point.compare(to: point, using: comparator)
            #expect(result == .orderedSame)
        }
    }

    @Test("Comparator antisymmetry")
    func testComparatorAntisymmetry() {
        let point1 = CGPoint(x: 1, y: 2)
        let point2 = CGPoint(x: 3, y: 4)
        let comparators: [CGPoint.Comparator] = [
            .xThenY,
            .yThenX,
            .relativeAngleFrom(CGPoint.zero),
            .distanceFrom(CGPoint.zero)
        ]

        for comparator in comparators {
            let result1 = point1.compare(to: point2, using: comparator)
            let result2 = point2.compare(to: point1, using: comparator)

            if result1 == .orderedAscending {
                #expect(result2 == .orderedDescending)
            } else if result1 == .orderedDescending {
                #expect(result2 == .orderedAscending)
            } else {
                #expect(result2 == .orderedSame)
            }
        }
    }

    @Test("Comparator transitivity")
    func testComparatorTransitivity() {
        let point1 = CGPoint(x: 1, y: 1)
        let point2 = CGPoint(x: 2, y: 2)
        let point3 = CGPoint(x: 3, y: 3)

        // Test with xThenY comparator
        let result12 = point1.compare(to: point2, using: .xThenY)
        let result23 = point2.compare(to: point3, using: .xThenY)
        let result13 = point1.compare(to: point3, using: .xThenY)

        #expect(result12 == .orderedAscending)
        #expect(result23 == .orderedAscending)
        #expect(result13 == .orderedAscending) // Transitivity
    }

    // MARK: - Edge Cases and Special Values

    @Test("Comparator with floating point precision")
    func testComparatorFloatingPointPrecision() {
        let point1 = CGPoint(x: 1.0, y: 2.0)
        let point2 = CGPoint(x: 1.0000001, y: 2.0)

        // These should be considered different due to floating point precision
        let result = point1.compare(to: point2, using: .xThenY)
        #expect(result == .orderedAscending)
    }

    @Test("Comparator with very large coordinates")
    func testComparatorLargeCoordinates() {
        let point1 = CGPoint(x: 1_000_000, y: 1_000_000)
        let point2 = CGPoint(x: 1_000_001, y: 1_000_000)

        let result = point1.compare(to: point2, using: .xThenY)
        #expect(result == .orderedAscending)
    }

    @Test("Comparator with very small coordinates")
    func testComparatorSmallCoordinates() {
        let point1 = CGPoint(x: 0.000001, y: 0.000001)
        let point2 = CGPoint(x: 0.000002, y: 0.000001)

        let result = point1.compare(to: point2, using: .xThenY)
        #expect(result == .orderedAscending)
    }

    // MARK: - Real-world Usage Scenarios

    @Test("Sorting points with xThenY comparator")
    func testSortingWithXThenY() {
        let points = [
            CGPoint(x: 3, y: 1),
            CGPoint(x: 1, y: 3),
            CGPoint(x: 2, y: 2),
            CGPoint(x: 1, y: 1)
        ]

        let sortedPoints = points.sorted { point1, point2 in
            point1.compare(to: point2, using: .xThenY) == .orderedAscending
        }

        #expect(sortedPoints[0] == CGPoint(x: 1, y: 1))
        #expect(sortedPoints[1] == CGPoint(x: 1, y: 3))
        #expect(sortedPoints[2] == CGPoint(x: 2, y: 2))
        #expect(sortedPoints[3] == CGPoint(x: 3, y: 1))
    }

    @Test("Sorting points by angle around center")
    func testSortingByAngle() {
        let center = CGPoint.zero
        let points = [
            CGPoint(x: 0, y: 1),    // 90 degrees
            CGPoint(x: 1, y: 0),    // 0 degrees
            CGPoint(x: -1, y: 0),   // 180 degrees
            CGPoint(x: 0, y: -1)    // -90 degrees
        ]

        let sortedPoints = points.sorted { point1, point2 in
            point1.compare(to: point2, using: .relativeAngleFrom(center)) == .orderedAscending
        }

        // Should be ordered by increasing angle
        #expect(sortedPoints[0] == CGPoint(x: 0, y: -1))  // -90 degrees
        #expect(sortedPoints[1] == CGPoint(x: 1, y: 0))   // 0 degrees
        #expect(sortedPoints[2] == CGPoint(x: 0, y: 1))   // 90 degrees
        #expect(sortedPoints[3] == CGPoint(x: -1, y: 0))  // 180 degrees
    }

    @Test("Sorting points by distance from reference")
    func testSortingByDistance() {
        let reference = CGPoint.zero
        let points = [
            CGPoint(x: 3, y: 4),    // Distance 5
            CGPoint(x: 1, y: 0),    // Distance 1
            CGPoint(x: 0, y: 2),    // Distance 2
            CGPoint(x: 6, y: 8)     // Distance 10
        ]

        let sortedPoints = points.sorted { point1, point2 in
            point1.compare(to: point2, using: .distanceFrom(reference)) == .orderedAscending
        }

        #expect(sortedPoints[0] == CGPoint(x: 1, y: 0))   // Distance 1
        #expect(sortedPoints[1] == CGPoint(x: 0, y: 2))   // Distance 2
        #expect(sortedPoints[2] == CGPoint(x: 3, y: 4))   // Distance 5
        #expect(sortedPoints[3] == CGPoint(x: 6, y: 8))   // Distance 10
    }
}
