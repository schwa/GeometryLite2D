import Collections
import OrderedCollections
import OrderedCollections

public struct UndirectedValuedGraph<Vertex: Hashable, VertexValue, EdgeValue> {
    public typealias VertexValue = VertexValue
    public typealias EdgeValue = EdgeValue

    public typealias Edge = UndirectedGraph<Vertex>.Edge

    private var base: UndirectedGraph<Vertex>
    private var valuesByVertex: [Vertex: VertexValue] = [:]
    private var valuesByEdge: [Edge: EdgeValue] = [:]

    public init() {
        self.base = UndirectedGraph()
    }

    @discardableResult
    public mutating func add(vertex: Vertex, value: VertexValue) -> Vertex {
        let vertex = base.add(vertex: vertex)
        valuesByVertex[vertex] = value
        return vertex
    }

    @discardableResult
    public mutating func add(edge: Edge, value: EdgeValue) -> Edge {
        let edge = base.add(edge: edge)
        valuesByEdge[edge] = value
        return edge
    }

    public mutating func remove(vertex: Vertex) {
        base.remove(vertex: vertex)
        valuesByVertex.removeValue(forKey: vertex)
        valuesByEdge = valuesByEdge.filter { $0.key.from != vertex && $0.key.to != vertex }
    }

    public mutating func remove(edge: Edge) {
        base.remove(edge: edge)
        valuesByEdge.removeValue(forKey: edge)
    }

    public func value(for vertex: Vertex) -> VertexValue? {
        valuesByVertex[vertex]
    }

    public mutating func update(value: VertexValue, for vertex: Vertex) {
        valuesByVertex[vertex] = value
    }

    public func value(for edge: Edge) -> EdgeValue? {
        valuesByEdge[edge]
    }

    public func neighbors(of vertex: Vertex) -> OrderedSet<Vertex> {
        base.neighbors(of: vertex)
    }

    public func contains(vertex: Vertex) -> Bool {
        base.contains(vertex: vertex)
    }

    public func contains(edge: Edge) -> Bool {
        base.contains(edge: edge)
    }

    public var vertices: OrderedSet<Vertex> {
        get {
            base.vertices
        }
        set {
            base.vertices = newValue
        }
    }

    public var edges: OrderedSet<Edge> {
        base.edges
    }

    public var edgeValues: [(Edge, EdgeValue)] {
        base.edges.compactMap { edge in
            valuesByEdge[edge].map { (edge, $0) }
        }
    }
}
