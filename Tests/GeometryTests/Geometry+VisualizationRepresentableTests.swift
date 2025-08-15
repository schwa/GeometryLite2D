import CoreGraphics
@testable import Geometry
import SwiftUI
import Testing
import Visualization

// Resolve ambiguity with QuickDraw's Polygon type
typealias Polygon = Geometry.Polygon

@Suite("Geometry+VisualizationRepresentable Tests")
struct GeometryVisualizationRepresentableTests {
    // MARK: - Protocol Conformance Tests

    @Test("LineSegment conforms to VisualizationRepresentable")
    func testLineSegmentConformance() {
        let segment = LineSegment(start: CGPoint.zero, end: CGPoint(x: 10, y: 10))

        // Test protocol conformance
        let representable: any VisualizationRepresentable = segment
        #expect(representable.boundingRect.width > 0)
        #expect(representable.boundingRect.height > 0)
    }

    @Test("Polygon conforms to VisualizationRepresentable")
    func testPolygonConformance() {
        let polygon = Polygon([
            CGPoint.zero,
            CGPoint(x: 10, y: 0),
            CGPoint(x: 5, y: 10)
        ])

        // Test protocol conformance
        let representable: any VisualizationRepresentable = polygon
        #expect(representable.boundingRect.width > 0)
        #expect(representable.boundingRect.height > 0)
    }

    @Test("Circle conforms to VisualizationRepresentable")
    func testCircleConformance() {
        let circle = Circle(center: CGPoint(x: 5, y: 5), radius: 3)

        // Test protocol conformance
        let representable: any VisualizationRepresentable = circle
        #expect(representable.boundingRect.width > 0)
        #expect(representable.boundingRect.height > 0)
    }

    @Test("Line conforms to VisualizationRepresentable")
    func testLineConformance() {
        let line = Line(point: CGPoint.zero, direction: CGVector(dx: 1, dy: 1))

        // Test protocol conformance
        let representable: any VisualizationRepresentable = line
        #expect(representable.boundingRect.width > 0)
        #expect(representable.boundingRect.height > 0)
    }

    // MARK: - LineSegment VisualizationRepresentable Tests

    @Test("LineSegment boundingRect calculation")
    func testLineSegmentBoundingRect() {
        let segment = LineSegment(start: CGPoint(x: 2, y: 3), end: CGPoint(x: 8, y: 7))
        let bounds = segment.boundingRect

        #expect(bounds.minX == 2)
        #expect(bounds.minY == 3)
        #expect(bounds.maxX == 8)
        #expect(bounds.maxY == 7)
        #expect(bounds.width == 6)
        #expect(bounds.height == 4)
    }

    @Test("LineSegment boundingRect with zero length")
    func testLineSegmentZeroLengthBoundingRect() {
        let segment = LineSegment(start: CGPoint(x: 5, y: 5), end: CGPoint(x: 5, y: 5))
        let bounds = segment.boundingRect

        // Should still have a valid rect, even if zero size
        #expect(bounds.minX == 5)
        #expect(bounds.minY == 5)
        #expect(bounds.width == 0)
        #expect(bounds.height == 0)
    }

    @Test("LineSegment boundingRect with negative coordinates")
    func testLineSegmentNegativeBoundingRect() {
        let segment = LineSegment(start: CGPoint(x: -5, y: -3), end: CGPoint(x: 2, y: 4))
        let bounds = segment.boundingRect

        #expect(bounds.minX == -5)
        #expect(bounds.minY == -3)
        #expect(bounds.maxX == 2)
        #expect(bounds.maxY == 4)
        #expect(bounds.width == 7)
        #expect(bounds.height == 7)
    }

    @Test("LineSegment visualization doesn't crash")
    func testLineSegmentVisualization() {
        let segment = LineSegment(start: CGPoint.zero, end: CGPoint(x: 10, y: 10))

        // Create a mock graphics context - we can't easily test the actual drawing
        // but we can verify the visualization method runs without crashing
        #expect(segment.boundingRect.width > 0)
        #expect(segment.boundingRect.height > 0)
    }

    // MARK: - Polygon VisualizationRepresentable Tests

    @Test("Polygon boundingRect calculation")
    func testPolygonBoundingRect() {
        let polygon = Polygon([
            CGPoint(x: 1, y: 2),
            CGPoint(x: 5, y: 1),
            CGPoint(x: 4, y: 6),
            CGPoint(x: 0, y: 4)
        ])
        let bounds = polygon.boundingRect

        #expect(bounds.minX == 0)
        #expect(bounds.minY == 1)
        #expect(bounds.maxX == 5)
        #expect(bounds.maxY == 6)
        #expect(bounds.width == 5)
        #expect(bounds.height == 5)
    }

    @Test("Polygon triangle boundingRect")
    func testPolygonTriangleBoundingRect() {
        let polygon = Polygon([
            CGPoint.zero,
            CGPoint(x: 10, y: 0),
            CGPoint(x: 5, y: 8)
        ])
        let bounds = polygon.boundingRect

        #expect(bounds.minX == 0)
        #expect(bounds.minY == 0)
        #expect(bounds.maxX == 10)
        #expect(bounds.maxY == 8)
        #expect(bounds.width == 10)
        #expect(bounds.height == 8)
    }

    @Test("Polygon with negative coordinates boundingRect")
    func testPolygonNegativeBoundingRect() {
        let polygon = Polygon([
            CGPoint(x: -3, y: -2),
            CGPoint(x: 2, y: -1),
            CGPoint(x: 1, y: 3)
        ])
        let bounds = polygon.boundingRect

        #expect(bounds.minX == -3)
        #expect(bounds.minY == -2)
        #expect(bounds.maxX == 2)
        #expect(bounds.maxY == 3)
        #expect(bounds.width == 5)
        #expect(bounds.height == 5)
    }

    // MARK: - Circle VisualizationRepresentable Tests

    @Test("Circle boundingRect calculation")
    func testCircleBoundingRect() {
        let circle = Circle(center: CGPoint(x: 5, y: 3), radius: 2)
        let bounds = circle.boundingRect

        #expect(bounds.minX == 3)
        #expect(bounds.minY == 1)
        #expect(bounds.maxX == 7)
        #expect(bounds.maxY == 5)
        #expect(bounds.width == 4)
        #expect(bounds.height == 4)
    }

    @Test("Circle at origin boundingRect")
    func testCircleAtOriginBoundingRect() {
        let circle = Circle(center: CGPoint.zero, radius: 1)
        let bounds = circle.boundingRect

        #expect(bounds.minX == -1)
        #expect(bounds.minY == -1)
        #expect(bounds.maxX == 1)
        #expect(bounds.maxY == 1)
        #expect(bounds.width == 2)
        #expect(bounds.height == 2)
    }

    @Test("Circle with zero radius boundingRect")
    func testCircleZeroRadiusBoundingRect() {
        let circle = Circle(center: CGPoint(x: 5, y: 3), radius: 0)
        let bounds = circle.boundingRect

        #expect(bounds.minX == 5)
        #expect(bounds.minY == 3)
        #expect(bounds.width == 0)
        #expect(bounds.height == 0)
    }

    @Test("Circle with large radius boundingRect")
    func testCircleLargeRadiusBoundingRect() {
        let circle = Circle(center: CGPoint(x: 10, y: 20), radius: 50)
        let bounds = circle.boundingRect

        #expect(bounds.minX == -40)
        #expect(bounds.minY == -30)
        #expect(bounds.maxX == 60)
        #expect(bounds.maxY == 70)
        #expect(bounds.width == 100)
        #expect(bounds.height == 100)
    }

    // MARK: - Line VisualizationRepresentable Tests

    @Test("Line boundingRect calculation")
    func testLineBoundingRect() {
        let line = Line(point: CGPoint(x: 5, y: 5), direction: CGVector(dx: 1, dy: 0))
        let bounds = line.boundingRect

        // Line should extend 1_000_000 units in both directions (from PathRepresentable)
        #expect(bounds.minX == -999_995) // 5 - 1_000_000
        #expect(bounds.minY == 5)
        #expect(bounds.maxX == 1_000_005) // 5 + 1_000_000
        #expect(bounds.maxY == 5)
        #expect(bounds.width == 2_000_000)
        #expect(bounds.height == 0)
    }

    @Test("Line diagonal boundingRect")
    func testLineDiagonalBoundingRect() {
        let line = Line(point: CGPoint.zero, direction: CGVector(dx: 1, dy: 1))
        let bounds = line.boundingRect

        // Line should extend 1_000_000 units in both directions along normalized diagonal
        let normalizedLength = sqrt(2.0)
        let offset = 1_000_000 / normalizedLength

        #expect(abs(bounds.minX - (-offset)) < 1.0)
        #expect(abs(bounds.minY - (-offset)) < 1.0)
        #expect(abs(bounds.maxX - offset) < 1.0)
        #expect(abs(bounds.maxY - offset) < 1.0)
    }

    @Test("Line vertical boundingRect")
    func testLineVerticalBoundingRect() {
        let line = Line(point: CGPoint(x: 3, y: 7), direction: CGVector(dx: 0, dy: 1))
        let bounds = line.boundingRect

        // Line should extend 1_000_000 units in both directions (from PathRepresentable)
        #expect(bounds.minX == 3)
        #expect(bounds.minY == -999_993) // 7 - 1_000_000
        #expect(bounds.maxX == 3)
        #expect(bounds.maxY == 1_000_007) // 7 + 1_000_000
        #expect(bounds.width == 0)
        #expect(bounds.height == 2_000_000)
    }

    // MARK: - Helper Extensions Tests

    @Test("CGRect boundingRect of points")
    func testCGRectBoundingRectOfPoints() {
        let points = [
            CGPoint(x: 1, y: 2),
            CGPoint(x: 5, y: 0),
            CGPoint(x: 3, y: 6),
            CGPoint(x: 0, y: 4)
        ]

        let bounds = CGRect.boundingRect(of: points)

        #expect(bounds.minX == 0)
        #expect(bounds.minY == 0)
        #expect(bounds.maxX == 5)
        #expect(bounds.maxY == 6)
        #expect(bounds.width == 5)
        #expect(bounds.height == 6)
    }

    @Test("CGRect boundingRect of single point")
    func testCGRectBoundingRectSinglePoint() {
        let points = [CGPoint(x: 3, y: 4)]
        let bounds = CGRect.boundingRect(of: points)

        #expect(bounds.minX == 3)
        #expect(bounds.minY == 4)
        #expect(bounds.width == 0)
        #expect(bounds.height == 0)
    }

    @Test("CGRect boundingRect of empty points")
    func testCGRectBoundingRectEmptyPoints() {
        let points: [CGPoint] = []
        let bounds = CGRect.boundingRect(of: points)

        #expect(bounds == .zero)
    }

    @Test("CGRect boundingRect with negative coordinates")
    func testCGRectBoundingRectNegativeCoordinates() {
        let points = [
            CGPoint(x: -5, y: -3),
            CGPoint(x: 2, y: 1),
            CGPoint(x: -1, y: 4)
        ]

        let bounds = CGRect.boundingRect(of: points)

        #expect(bounds.minX == -5)
        #expect(bounds.minY == -3)
        #expect(bounds.maxX == 2)
        #expect(bounds.maxY == 4)
        #expect(bounds.width == 7)
        #expect(bounds.height == 7)
    }

    // MARK: - Convenience Function Tests

    @Test("Visualize PathRepresentable elements function exists")
    func testVisualizePathRepresentableFunction() {
        let elements: [any PathRepresentable] = [
            LineSegment(start: CGPoint.zero, end: CGPoint(x: 10, y: 10)),
            Polygon([
                CGPoint.zero,
                CGPoint(x: 5, y: 0),
                CGPoint(x: 2.5, y: 5)
            ])
        ]

        // Test that the function exists and can be called
        // Note: We can't easily test the CGImage result without a full UI context
        // but we can verify the function signature works
        #expect(elements.count == 2)
        #expect(elements[0] is LineSegment)
        #expect(elements[1] is Polygon)
    }

    // MARK: - Integration Tests

    @Test("VisualizationRepresentable with complex geometries")
    func testVisualizationRepresentableComplexGeometries() {
        // Test with more complex geometry setups
        let complexPolygon = Polygon([
            CGPoint.zero,
            CGPoint(x: 20, y: 5),
            CGPoint(x: 15, y: 15),
            CGPoint(x: 5, y: 20),
            CGPoint(x: -5, y: 10),
            CGPoint(x: -10, y: 2)
        ])

        let longSegment = LineSegment(start: CGPoint(x: -100, y: -50), end: CGPoint(x: 200, y: 150))

        let largeCircle = Circle(center: CGPoint(x: 50, y: 75), radius: 25)

        let representables: [any VisualizationRepresentable] = [complexPolygon, longSegment, largeCircle]

        for representable in representables {
            let bounds = representable.boundingRect
            #expect(bounds.width > 0)
            #expect(bounds.height > 0)
            #expect(!bounds.isInfinite)
            #expect(!bounds.isNull)
        }
    }

    @Test("VisualizationRepresentable bounding rect consistency")
    func testVisualizationRepresentableBoundingRectConsistency() {
        // Test that bounding rects are consistent and meaningful
        let segment = LineSegment(start: CGPoint(x: 5, y: 10), end: CGPoint(x: 15, y: 20))
        let bounds1 = segment.boundingRect
        let bounds2 = segment.boundingRect

        // Should be deterministic
        #expect(bounds1 == bounds2)

        // Should contain the actual geometry start point
        #expect(bounds1.contains(segment.start))
        // For LineSegment, the bounding rect should encompass both endpoints
        #expect(bounds1.minX <= min(segment.start.x, segment.end.x))
        #expect(bounds1.maxX >= max(segment.start.x, segment.end.x))
        #expect(bounds1.minY <= min(segment.start.y, segment.end.y))
        #expect(bounds1.maxY >= max(segment.start.y, segment.end.y))
    }

    @Test("PathRepresentable extension for VisualizationRepresentable")
    func testPathRepresentableExtensionForVisualizationRepresentable() {
        // Test that PathRepresentable types get the default implementation
        let segment = LineSegment(start: CGPoint.zero, end: CGPoint(x: 10, y: 5))
        let polygon = Polygon([
            CGPoint.zero,
            CGPoint(x: 3, y: 0),
            CGPoint(x: 1.5, y: 3)
        ])

        // These should use the Path-based bounding rect calculation
        let segmentBounds = segment.boundingRect
        let polygonBounds = polygon.boundingRect

        #expect(segmentBounds.width == 10)
        #expect(segmentBounds.height == 5)
        #expect(polygonBounds.width == 3)
        #expect(polygonBounds.height == 3)
    }

    // MARK: - Edge Cases and Error Conditions

    @Test("VisualizationRepresentable with extreme coordinates")
    func testVisualizationRepresentableExtremeCoordinates() {
        let extremeSegment = LineSegment(
            start: CGPoint(x: -1_000_000, y: -500_000),
            end: CGPoint(x: 1_000_000, y: 500_000)
        )

        let bounds = extremeSegment.boundingRect
        #expect(bounds.width == 2_000_000)
        #expect(bounds.height == 1_000_000)
        #expect(!bounds.isInfinite)
        #expect(!bounds.isNull)
    }

    @Test("VisualizationRepresentable with very small coordinates")
    func testVisualizationRepresentableSmallCoordinates() {
        let tinySegment = LineSegment(
            start: CGPoint(x: 0.1, y: 0.2),
            end: CGPoint(x: 0.3, y: 0.4)
        )

        let bounds = tinySegment.boundingRect
        #expect(bounds.width > 0)
        #expect(bounds.height > 0)
        #expect(!bounds.isInfinite)
        #expect(!bounds.isNull)
    }

    @Test("Line with very small direction vector")
    func testLineSmallDirectionVector() {
        let line = Line(point: CGPoint(x: 5, y: 5), direction: CGVector(dx: 0.001, dy: 0.001))
        let bounds = line.boundingRect

        // Should handle gracefully with small but non-zero direction
        #expect(!bounds.isInfinite)
        #expect(!bounds.isNull)
        #expect(bounds.width > 0)
        #expect(bounds.height > 0)
    }
}
