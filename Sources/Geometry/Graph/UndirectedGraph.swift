import Collections

public struct UndirectedGraph<Vertex: Hashable> {
    private var base: DirectedGraph<Vertex>

    public typealias Edge = DirectedGraph<Vertex>.Edge

    public init() {
        self.base = DirectedGraph()
    }

    @discardableResult
    public mutating func add(vertex: Vertex) -> Vertex {
        base.add(vertex: vertex)
    }

    @discardableResult
    public mutating func add(edge: Edge) -> Edge {
        base.add(edge: edge)
        base.add(edge: .init(from: edge.to, to: edge.from))
        return edge
    }

    public mutating func remove(vertex: Vertex) {
        base.remove(vertex: vertex)
    }

    public mutating func remove(edge: Edge) {
        base.remove(edge: edge)
        base.remove(edge: .init(from: edge.to, to: edge.from))
    }

    public func neighbors(of vertex: Vertex) -> OrderedSet<Vertex> {
        base.neighbors(of: vertex)
    }

    public func contains(vertex: Vertex) -> Bool {
        base.contains(vertex: vertex)
    }

    public func contains(edge: Edge) -> Bool {
        base.contains(edge: edge) || base.contains(edge: .init(from: edge.to, to: edge.from))
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
        var seen = Set<Set<Vertex>>()
        return base.edges.filter {
            seen.insert([$0.from, $0.to]).inserted
        }
    }
}
