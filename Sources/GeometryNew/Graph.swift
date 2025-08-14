import CoreGraphics
import Foundation

// MARK: - Graph Types

/// A graph represented as an adjacency list
public typealias Graph<Vertex: Hashable> = [Vertex: Set<Vertex>]

// MARK: - Graph Building

/// Builds an undirected graph from a collection of edges
public func buildGraph<Vertex: Hashable>(from edges: [(Vertex, Vertex)]) -> Graph<Vertex> {
    var graph: Graph<Vertex> = [:]

    for (v1, v2) in edges {
        graph[v1, default: []].insert(v2)
        graph[v2, default: []].insert(v1)
    }

    return graph
}

/// Builds an undirected graph from line segments
public func buildGraph(from segments: [LineSegment]) -> Graph<CGPoint> {
    var graph: Graph<CGPoint> = [:]

    for segment in segments {
        graph[segment.start, default: []].insert(segment.end)
        graph[segment.end, default: []].insert(segment.start)
    }

    return graph
}

// MARK: - Cycle Detection

/// Finds all simple cycles in an undirected graph (only simple loops, no interior vertices)
public func findAllCycles<Vertex: Hashable>(in graph: Graph<Vertex>) -> [[Vertex]] {
    var foundCycles = Set<[Vertex]>()

    // For each vertex, try to find cycles starting from it
    for startVertex in graph.keys {
        findCyclesFromVertex(startVertex, in: graph, foundCycles: &foundCycles)
    }

    // Validate that each cycle is a true simple loop
    let validCycles = foundCycles.filter { cycle in
        isSimpleLoop(cycle, in: graph)
    }

    return Array(validCycles)
}

/// Find cycles starting from a given vertex using DFS
private func findCyclesFromVertex<Vertex: Hashable>(
    _ start: Vertex,
    in graph: Graph<Vertex>,
    foundCycles: inout Set<[Vertex]>
) {
    var path: [Vertex] = []
    var visited = Set<Vertex>()

    func dfs(_ current: Vertex, _ parent: Vertex?) {
        path.append(current)
        visited.insert(current)

        guard let neighbors = graph[current] else {
            path.removeLast()
            return
        }

        for neighbor in neighbors {
            // Skip the edge we came from
            if let p = parent, neighbor == p { continue }

            // Check if we found a cycle back to start
            if neighbor == start && path.count >= 3 {
                // Normalize the cycle to avoid duplicates
                let cycle = normalizeCycle(path)
                foundCycles.insert(cycle)
            } else if !visited.contains(neighbor) && path.count < 20 {
                dfs(neighbor, current)
            }
        }

        path.removeLast()
        visited.remove(current)
    }

    dfs(start, nil)
}

/// Normalize a cycle by rotating it so the smallest vertex comes first and ensuring consistent winding
private func normalizeCycle<Vertex: Hashable>(_ cycle: [Vertex]) -> [Vertex] {
    guard let minVertex = cycle.min(by: { "\($0)" < "\($1)" }),
          let minIndex = cycle.firstIndex(of: minVertex) else {
        return cycle
    }

    // Rotate so min vertex is first
    let rotated = Array(cycle[minIndex...] + cycle[..<minIndex])

    // Check if we should reverse to ensure consistent winding
    // Compare the second vertex with the last vertex (which would be second if reversed)
    if rotated.count > 2 {
        let secondVertex = rotated[1]
        let lastVertex = rotated[rotated.count - 1]

        // If last vertex is "smaller" than second, reverse the cycle
        if "\(lastVertex)" < "\(secondVertex)" {
            return [rotated[0]] + rotated[1...].reversed()
        }
    }

    return rotated
}

/// Verify that a cycle is a simple loop (each vertex connects to exactly 2 others in the cycle)
private func isSimpleLoop<Vertex: Hashable>(_ cycle: [Vertex], in graph: Graph<Vertex>) -> Bool {
    guard cycle.count >= 3 else { return false }

    // Check each vertex in the cycle
    for i in 0..<cycle.count {
        let current = cycle[i]
        let prev = cycle[(i - 1 + cycle.count) % cycle.count]
        let next = cycle[(i + 1) % cycle.count]

        // The vertex should connect to prev and next
        guard let neighbors = graph[current] else { return false }

        if !neighbors.contains(prev) || !neighbors.contains(next) {
            return false
        }

        // Count how many vertices in the cycle this vertex connects to
        let connectionsInCycle = cycle.filter { neighbors.contains($0) }.count

        // In a simple loop, each vertex should connect to exactly 2 others in the cycle
        if connectionsInCycle != 2 {
            return false  // This vertex has interior connections
        }
    }

    return true
}
