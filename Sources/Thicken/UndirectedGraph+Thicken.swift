import CoreGraphics
import Geometry
import GeometryCollections
import SwiftUI

// MARK: - Graph Thickening

public extension UndirectedGraph where Vertex == CGPoint {
    /// Returns thickened atoms for this graph
    ///
    /// Splits each edge at its midpoint and creates junctions at each vertex.
    /// Half-edges always use butt caps at midpoints where they meet.
    ///
    /// - Parameters:
    ///   - width: Stroke width
    ///   - joinStyle: Join style at vertices
    ///   - capStyle: Cap style for degree-1 vertices (leaf endpoints only)
    /// - Returns: Array of atoms (segments and knee caps)
    func thickened(
        width: CGFloat,
        joinStyle: JoinStyle = .miter,
        capStyle: CapStyle = .butt
    ) -> [Atom] {
        var atoms: [Atom] = []

        // Pre-compute degree of each vertex to identify tails
        var vertexDegree: [CGPoint: Int] = [:]
        for vertex in vertices {
            vertexDegree[vertex] = neighbors(of: vertex).count
        }

        // For each vertex, collect midpoints of connected edges and create a junction
        for vertex in vertices {
            let neighbors = Array(neighbors(of: vertex))

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
            let junction = Junction(center: vertex, vertices: midpoints)
            let vertexAtoms = junction.thickened(
                width: width,
                joinStyle: joinStyle,
                capStyles: capStyles
            )
            atoms.append(contentsOf: vertexAtoms)
        }

        return atoms
    }
}
