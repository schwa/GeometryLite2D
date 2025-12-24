import CoreGraphics
import Geometry
import GeometryCollections
import SwiftUI

// MARK: - Graph Thickening

/// Process an undirected graph and return thickened atoms
///
/// Splits each edge at its midpoint and creates junctions at each vertex.
/// Half-edges always use butt caps at midpoints where they meet.
///
/// - Parameters:
///   - graph: The graph to thicken
///   - width: Stroke width
///   - joinStyle: Join style at vertices
///   - capStyle: Cap style for degree-1 vertices (leaf endpoints only)
/// - Returns: Array of atoms (segments and knee caps)
public func thickenGraph(
    _ graph: UndirectedGraph<CGPoint>,
    width: CGFloat,
    joinStyle: JoinStyle = .miter,
    capStyle: CapStyle = .butt
) -> [Atom] {
    var atoms: [Atom] = []

    // Pre-compute degree of each vertex to identify tails
    var vertexDegree: [CGPoint: Int] = [:]
    for vertex in graph.vertices {
        vertexDegree[vertex] = graph.neighbors(of: vertex).count
    }

    // For each vertex, collect midpoints of connected edges and create a junction
    for vertex in graph.vertices {
        let neighbors = Array(graph.neighbors(of: vertex))

        // Calculate midpoints of edges to this vertex
        let midpoints: [CGPoint] = neighbors.map { neighbor in
            CGPoint(
                x: (vertex.x + neighbor.x) / 2,
                y: (vertex.y + neighbor.y) / 2
            )
        }

        // Determine cap style for each half-edge:
        // - If this vertex is degree 1 (tail tip), use specified capStyle
        // - Otherwise use butt (half-edges meet at midpoints)
        let thisDegree = vertexDegree[vertex] ?? 0
        let capStyles: [CapStyle] = neighbors.map { _ in
            thisDegree == 1 ? capStyle : .butt
        }

        // Use junction to thicken this vertex's half-edges
        let vertexAtoms = junction(
            center: vertex,
            endpoints: midpoints,
            width: width,
            joinStyle: joinStyle,
            capStyles: capStyles
        )
        atoms.append(contentsOf: vertexAtoms)
    }

    return atoms
}
