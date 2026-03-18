import Collections
import OrderedCollections

/// A minimal, reusable directed graph structure where edges and vertices are generic and hashable.
public struct DirectedGraph<Vertex: Hashable> {
    public struct Edge: Hashable {
        public let from: Vertex
        public let to: Vertex

        public init(from: Vertex, to: Vertex) {
            self.from = from
            self.to = to
        }
    }

    // MARK: - Stored Properties

    public var vertices = OrderedSet<Vertex>()
    public var edges = OrderedSet<Edge>()
    private var adjacency = OrderedDictionary<Vertex, OrderedSet<Vertex>>()

    // MARK: - Initialization

    public init() {
    }

    // MARK: - Vertex Operations

    @discardableResult
    public mutating func add(vertex: Vertex) -> Vertex {
        if !vertices.contains(vertex) {
            vertices.append(vertex)
            adjacency[vertex] = []
        }
        return vertex
    }

    public mutating func remove(vertex: Vertex) {
        vertices.remove(vertex)
        adjacency.removeValue(forKey: vertex)

        for (key, neighbors) in adjacency {
            if neighbors.contains(vertex) {
                adjacency[key]?.remove(vertex)
            }
        }

        edges.removeAll { $0.from == vertex || $0.to == vertex }
    }

    // MARK: - Edge Operations

    @discardableResult
    public mutating func add(edge: Edge) -> Edge {
        add(vertex: edge.from)
        add(vertex: edge.to)
        if !edges.contains(edge) {
            edges.append(edge)
            adjacency[edge.from, default: []].append(edge.to)
        }
        return edge
    }

    public mutating func remove(edge: Edge) {
        edges.remove(edge)
        adjacency[edge.from]?.remove(edge.to)
    }

    // MARK: - Accessors

    public func neighbors(of vertex: Vertex) -> OrderedSet<Vertex> {
        adjacency[vertex] ?? []
    }

    public func contains(vertex: Vertex) -> Bool {
        vertices.contains(vertex)
    }

    public func contains(edge: Edge) -> Bool {
        edges.contains(edge)
    }
}
