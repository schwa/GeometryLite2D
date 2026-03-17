import Testing
import CoreGraphics
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
    let voronoiEdges = computeVoronoiEdges(from: triangles)

    #expect(!voronoiEdges.isEmpty)
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
