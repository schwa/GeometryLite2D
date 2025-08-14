import Collections

public extension GraphProtocol {
    func connectedComponentsOfEdges() -> [[Edge]] {
        var visited = OrderedSet<Vertex>()
        var components: [[Edge]] = []
        let edgeSet = OrderedSet(edges)

        for vertex in vertices {
            guard !visited.contains(vertex) else {
                continue
            }
            var stack: [Vertex] = [vertex]
            var componentEdges: OrderedSet<Edge> = []
            while let vertex = stack.popLast() {
                guard visited.append(vertex).inserted else {
                    continue
                }
                for neighbor in neighbors(of: vertex) {
                    stack.append(neighbor)
                    // Try both edge directions (works for undirected or symmetric graphs)
                    let edge = edgeSet.first {
                        ($0.from == vertex && $0.to == neighbor) || ($0.from == neighbor && $0.to == vertex)
                    }
                    if let edge {
                        componentEdges.append(edge)
                    }
                }
            }
            components.append(Array(componentEdges))
        }
        return components
    }
}
