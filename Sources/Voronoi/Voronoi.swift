import CoreGraphics
import Geometry

/// Represents an edge in a Voronoi diagram.
/// Edges can be either line segments (between two circumcenters) or rays (extending to infinity).
public struct VoronoiEdge: Sendable {
    public enum Kind: Sendable {
        case segment(LineSegment)
        case ray(Ray)
    }

    /// The primary site (point) associated with this edge
    public var leftSite: CGPoint
    /// The secondary site, if this is an internal edge (nil for boundary edges)
    public var rightSite: CGPoint?
    /// The geometric representation of the edge
    public var kind: Kind

    public init(leftSite: CGPoint, rightSite: CGPoint?, kind: Kind) {
        self.leftSite = leftSite
        self.rightSite = rightSite
        self.kind = kind
    }
}

extension VoronoiEdge: CustomDebugStringConvertible {
    public var debugDescription: String {
        "VoronoiEdge(\(kind), \(leftSite), \(rightSite.map(String.init(describing:)) ?? "nil"))"
    }
}

extension VoronoiEdge.Kind: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .segment(let segment):
            "\(segment)"
        case .ray(let ray):
            "\(ray)"
        }
    }
}

public extension VoronoiEdge {
    var isSegment: Bool {
        switch kind {
        case .segment: return true
        case .ray: return false
        }
    }

    var isRay: Bool {
        !isSegment
    }
}

/// Computes the Voronoi diagram edges from a Delaunay triangulation.
/// - Parameter triangles: The Delaunay triangulation triangles
/// - Returns: Array of Voronoi edges
public func computeVoronoiEdges(from triangles: [Triangle]) -> [VoronoiEdge] {
    struct EdgeKey: Hashable {
        let p1: CGPoint
        let p2: CGPoint

        init(_ p1: CGPoint, _ p2: CGPoint) {
            // Order points consistently
            if p1.x < p2.x || (p1.x == p2.x && p1.y < p2.y) {
                self.p1 = p1
                self.p2 = p2
            } else {
                self.p1 = p2
                self.p2 = p1
            }
        }
    }

    struct TriangleInfo {
        let triangle: Triangle
        let circumcenter: CGPoint
    }

    func findOppositeVertex(in triangle: Triangle, edge: EdgeKey) -> CGPoint {
        if triangle.a != edge.p1 && triangle.a != edge.p2 { return triangle.a }
        if triangle.b != edge.p1 && triangle.b != edge.p2 { return triangle.b }
        return triangle.c
    }

    var triangleInfos: [TriangleInfo] = []
    var edgeToTriangles: [EdgeKey: [Int]] = [:]

    // Step 1: Compute circumcenters and map edges to triangle indices
    for (index, triangle) in triangles.enumerated() {
        guard let circumcenter = triangle.circumcircle?.center else { continue }
        triangleInfos.append(TriangleInfo(triangle: triangle, circumcenter: circumcenter))

        let edges = [
            EdgeKey(triangle.a, triangle.b),
            EdgeKey(triangle.b, triangle.c),
            EdgeKey(triangle.c, triangle.a)
        ]

        for edge in edges {
            edgeToTriangles[edge, default: []].append(triangleInfos.count - 1)
        }
    }

    var voronoiEdges: [VoronoiEdge] = []

    // Step 2: Walk edges to create Voronoi edges
    for (edgeKey, triangleIndices) in edgeToTriangles {
        if triangleIndices.count == 2 {
            // Internal edge: create segment between two circumcenters
            let t1 = triangleInfos[triangleIndices[0]]
            let t2 = triangleInfos[triangleIndices[1]]
            let site1 = findOppositeVertex(in: t1.triangle, edge: edgeKey)
            let site2 = findOppositeVertex(in: t2.triangle, edge: edgeKey)

            let edge = VoronoiEdge(
                leftSite: site1,
                rightSite: site2,
                kind: .segment(LineSegment(start: t1.circumcenter, end: t2.circumcenter))
            )
            voronoiEdges.append(edge)
        } else if triangleIndices.count == 1 {
            // Boundary edge: create a ray
            let t = triangleInfos[triangleIndices[0]]
            let site = findOppositeVertex(in: t.triangle, edge: edgeKey)

            let mid = CGPoint(
                x: (edgeKey.p1.x + edgeKey.p2.x) / 2,
                y: (edgeKey.p1.y + edgeKey.p2.y) / 2
            )
            let dx = edgeKey.p2.x - edgeKey.p1.x
            let dy = edgeKey.p2.y - edgeKey.p1.y
            let normal = CGVector(dx: -dy, dy: dx) // Perpendicular vector

            // Ensure ray points away from site
            let toMid = CGVector(dx: mid.x - site.x, dy: mid.y - site.y)
            let dot = normal.dx * toMid.dx + normal.dy * toMid.dy
            let outward = dot > 0 ? normal : CGVector(dx: -normal.dx, dy: -normal.dy)

            let edge = VoronoiEdge(
                leftSite: site,
                rightSite: nil,
                kind: .ray(Ray(origin: t.circumcenter, direction: outward))
            )
            voronoiEdges.append(edge)
        }
    }

    return voronoiEdges
}

/// Builds a mapping from each site point to its associated Voronoi edges.
/// - Parameters:
///   - voronoiEdges: The Voronoi diagram edges
///   - triangles: The Delaunay triangulation triangles
/// - Returns: Dictionary mapping each site point to its Voronoi edges
public func buildEdgesBySite(
    from voronoiEdges: [VoronoiEdge],
    triangles: [Triangle]
) -> [CGPoint: [VoronoiEdge]] {
    var siteToEdges: [CGPoint: [VoronoiEdge]] = [:]

    // Build a lookup from circumcenter to triangle
    var circumcenterToTriangle: [CGPoint: Triangle] = [:]
    for triangle in triangles {
        if let center = triangle.circumcircle?.center {
            circumcenterToTriangle[center] = triangle
        }
    }

    for edge in voronoiEdges {
        var associatedSites: Set<CGPoint> = []

        switch edge.kind {
        case .segment(let segment):
            if let triangle1 = circumcenterToTriangle[segment.start] {
                associatedSites.formUnion([triangle1.a, triangle1.b, triangle1.c])
            }
            if let triangle2 = circumcenterToTriangle[segment.end] {
                associatedSites.formUnion([triangle2.a, triangle2.b, triangle2.c])
            }

        case .ray(let ray):
            if let triangle = circumcenterToTriangle[ray.origin] {
                associatedSites.formUnion([triangle.a, triangle.b, triangle.c])
            }
        }

        for site in associatedSites {
            siteToEdges[site, default: []].append(edge)
        }
    }

    return siteToEdges
}

/// Represents a Voronoi cell (region closest to a single site).
public struct VoronoiCell: Sendable {
    public var site: CGPoint
    public var polygon: Polygon_

    public init(site: CGPoint, polygon: Polygon_) {
        self.site = site
        self.polygon = polygon
    }
}

/// Computes the interior Voronoi cells (cells that are fully bounded).
/// - Parameters:
///   - points: The site points
///   - edges: The Voronoi edges
///   - triangles: The Delaunay triangulation triangles
/// - Returns: Array of tuples containing site points and their cell polygons (nil if unbounded)
public func computeInteriorVoronoiCells(
    points: [CGPoint],
    edges: [VoronoiEdge],
    triangles: [Triangle]
) -> [(CGPoint, Polygon_?)] {
    let edgesBySite = buildEdgesBySite(from: edges, triangles: triangles)
    return points.map { point in
        let siteEdges = edgesBySite[point] ?? []

        let cellEdges = siteEdges.filter {
            $0.isSegment && $0.leftSite != point && $0.rightSite != point
        }.compactMap { edge -> LineSegment? in
            if case let .segment(segment) = edge.kind {
                return segment
            }
            return nil
        }

        return (point, Polygon_(segments: cellEdges))
    }
}
