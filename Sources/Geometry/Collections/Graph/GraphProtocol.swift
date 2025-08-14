import Collections
import Foundation

public protocol EdgeProtocol: Hashable {
    associatedtype Vertex: Hashable
    var from: Vertex { get }
    var to: Vertex { get }
}

public protocol GraphProtocol {
    associatedtype Vertex: Hashable
    associatedtype Edge: EdgeProtocol where Edge.Vertex == Vertex
    associatedtype Vertices: Collection where Vertices.Element == Vertex
    associatedtype Edges: Collection where Edges.Element == Edge

    var vertices: Vertices { get }
    var edges: Edges { get }
    func neighbors(of vertex: Vertex) -> Vertices
}

extension DirectedGraph.Edge: EdgeProtocol {
}

extension DirectedGraph: GraphProtocol {
}

extension UndirectedGraph: GraphProtocol {
}

extension UndirectedValuedGraph: GraphProtocol {
}
