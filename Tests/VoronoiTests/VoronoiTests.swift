import Testing
import CoreGraphics
import Geometry
@testable import Voronoi

@Test func testDelaunayTriangulationBasic() {
    let points: [CGPoint] = [
        CGPoint(x: 0, y: 0),
        CGPoint(x: 1, y: 0),
        CGPoint(x: 0.5, y: 1)
    ]

    let triangles = delaunayTriangulation(points)
    #expect(triangles.count == 1)
}

@Test func testDelaunayTriangulationSquare() {
    let points: [CGPoint] = [
        CGPoint(x: 0, y: 0),
        CGPoint(x: 1, y: 0),
        CGPoint(x: 1, y: 1),
        CGPoint(x: 0, y: 1)
    ]

    let triangles = delaunayTriangulation(points)
    #expect(triangles.count == 2)
}

@Test func testVoronoiEdgesFromTriangulation() {
    let points: [CGPoint] = [
        CGPoint(x: 0.5, y: 0.5),
        CGPoint(x: 0.8, y: 0.6),
        CGPoint(x: 0.8, y: 0.4),
        CGPoint(x: 0.2, y: 0.4),
        CGPoint(x: 0.2, y: 0.6)
    ]

    let triangles = delaunayTriangulation(points)
    let edges = voronoiEdges(from: triangles)

    #expect(!edges.isEmpty)
}

@Test func testTriangleCircumcircle() {
    let triangle = Triangle(
        a: CGPoint(x: 0, y: 0),
        b: CGPoint(x: 1, y: 0),
        c: CGPoint(x: 0.5, y: 1)
    )

    let circumcircle = triangle.circumcircle
    #expect(circumcircle != nil)

    // All vertices should be on the circumcircle
    if let circle = circumcircle {
        #expect(circle.contains(triangle.a))
        #expect(circle.contains(triangle.b))
        #expect(circle.contains(triangle.c))
    }
}

@Test func testTriangleWinding() {
    let ccw = Triangle(a: [0, 0], b: [1, 0], c: [0.5, 1])
    #expect(ccw.winding == .counterClockwise)

    let cw = Triangle(a: [0, 0], b: [0.5, 1], c: [1, 0])
    #expect(cw.winding == .clockwise)

    let colinear = Triangle(a: [0, 0], b: [1, 0], c: [2, 0])
    #expect(colinear.winding == .colinear)
}

@Test func testCircleContains() {
    let circle = Circle(center: [0, 0], radius: 1)
    #expect(circle.contains([0, 0]))
    #expect(circle.contains([0.5, 0.5]))
    #expect(circle.contains([1, 0]))  // On boundary
    #expect(!circle.contains([2, 0]))
}

@Test func testIsCounterClockwise() {
    #expect(CGPoint.isCounterClockwise([0, 0], [1, 0], [0.5, 1]))
    #expect(!CGPoint.isCounterClockwise([0, 0], [0.5, 1], [1, 0]))
}
