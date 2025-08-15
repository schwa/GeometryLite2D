import Collections
@testable import Geometry
import Testing

@Suite("GraphProtocol+Components Tests")
struct GraphProtocolComponentsTests {
    @Test("Single connected component")
    func testSingleConnectedComponent() {
        var graph = UndirectedGraph<String>()

        graph.add(vertex: "A")
        graph.add(vertex: "B")
        graph.add(vertex: "C")

        graph.add(edge: UndirectedGraph<String>.Edge(from: "A", to: "B"))
        graph.add(edge: UndirectedGraph<String>.Edge(from: "B", to: "C"))

        let components = graph.connectedComponentsOfEdges()

        #expect(components.count == 1)
        #expect(components[0].count == 2) // Two edges in the component

        // Check that all edges are included
        let allEdges = Set(components.flatMap(\.self))
        #expect(allEdges.count == 2)
    }

    @Test("Multiple disconnected components")
    func testMultipleDisconnectedComponents() {
        var graph = UndirectedGraph<Int>()

        // Component 1: 1-2-3
        graph.add(edge: UndirectedGraph<Int>.Edge(from: 1, to: 2))
        graph.add(edge: UndirectedGraph<Int>.Edge(from: 2, to: 3))

        // Component 2: 4-5
        graph.add(edge: UndirectedGraph<Int>.Edge(from: 4, to: 5))

        // Component 3: 6 (isolated vertex, no edges)
        graph.add(vertex: 6)

        let components = graph.connectedComponentsOfEdges()

        // Should have 2 components with edges (isolated vertex 6 produces empty component)
        #expect(components.count == 3)

        // Find the component sizes
        let componentSizes = components.map(\.count).sorted()
        #expect(componentSizes == [0, 1, 2]) // Empty component, 1 edge, 2 edges

        // Total edges should be preserved
        let totalEdges = components.flatMap(\.self).count
        #expect(totalEdges == 3)
    }

    @Test("Empty graph")
    func testEmptyGraph() {
        let graph = UndirectedGraph<String>()
        let components = graph.connectedComponentsOfEdges()

        #expect(components.isEmpty)
    }

    @Test("Graph with isolated vertices only")
    func testGraphWithIsolatedVerticesOnly() {
        var graph = UndirectedGraph<String>()

        graph.add(vertex: "A")
        graph.add(vertex: "B")
        graph.add(vertex: "C")

        let components = graph.connectedComponentsOfEdges()

        // Should have 3 components, each empty (no edges)
        #expect(components.count == 3)
        for component in components {
            #expect(component.isEmpty)
        }
    }

    @Test("Star graph")
    func testStarGraph() {
        var graph = UndirectedGraph<String>()

        graph.add(vertex: "Center")
        graph.add(vertex: "A")
        graph.add(vertex: "B")
        graph.add(vertex: "C")

        graph.add(edge: UndirectedGraph<String>.Edge(from: "Center", to: "A"))
        graph.add(edge: UndirectedGraph<String>.Edge(from: "Center", to: "B"))
        graph.add(edge: UndirectedGraph<String>.Edge(from: "Center", to: "C"))

        let components = graph.connectedComponentsOfEdges()

        #expect(components.count == 1)
        #expect(components[0].count == 3) // Three edges in the star
    }

    @Test("Complete graph K4")
    func testCompleteGraphK4() {
        var graph = UndirectedGraph<Int>()

        // Add all vertices
        for i in 1...4 {
            graph.add(vertex: i)
        }

        // Add all possible edges
        for i in 1...3 {
            for j in (i + 1)...4 {
                graph.add(edge: UndirectedGraph<Int>.Edge(from: i, to: j))
            }
        }

        let components = graph.connectedComponentsOfEdges()

        #expect(components.count == 1)
        #expect(components[0].count == 6) // K4 has 6 edges
    }

    @Test("Linear chain")
    func testLinearChain() {
        var graph = UndirectedGraph<String>()

        let vertices = ["A", "B", "C", "D", "E"]

        // Create a linear chain: A-B-C-D-E
        for i in 0..<(vertices.count - 1) {
            graph.add(edge: UndirectedGraph<String>.Edge(from: vertices[i], to: vertices[i + 1]))
        }

        let components = graph.connectedComponentsOfEdges()

        #expect(components.count == 1)
        #expect(components[0].count == 4) // 4 edges in the chain
    }

    @Test("Complex multi-component graph")
    func testComplexMultiComponentGraph() {
        var graph = UndirectedGraph<String>()

        // Component 1: Triangle
        graph.add(edge: UndirectedGraph<String>.Edge(from: "A", to: "B"))
        graph.add(edge: UndirectedGraph<String>.Edge(from: "B", to: "C"))
        graph.add(edge: UndirectedGraph<String>.Edge(from: "C", to: "A"))

        // Component 2: Single edge
        graph.add(edge: UndirectedGraph<String>.Edge(from: "X", to: "Y"))

        // Component 3: Isolated vertex
        graph.add(vertex: "Z")

        let components = graph.connectedComponentsOfEdges()

        #expect(components.count == 3)

        // Sort components by size for consistent testing
        let sortedComponents = components.sorted { $0.count > $1.count }

        #expect(sortedComponents[0].count == 3) // Triangle
        #expect(sortedComponents[1].count == 1) // Single edge
        #expect(sortedComponents[2].isEmpty) // Isolated vertex
    }

    @Test("Self-loop edge")
    func testSelfLoopEdge() {
        var graph = UndirectedGraph<String>()

        graph.add(vertex: "A")
        graph.add(edge: UndirectedGraph<String>.Edge(from: "A", to: "A"))

        let components = graph.connectedComponentsOfEdges()

        #expect(components.count == 1)
        #expect(components[0].count == 1) // One self-loop edge
    }

    @Test("Works with DirectedGraph")
    func testWorksWithDirectedGraph() {
        var graph = DirectedGraph<Int>()

        // Create a small directed graph
        graph.add(edge: DirectedGraph<Int>.Edge(from: 1, to: 2))
        graph.add(edge: DirectedGraph<Int>.Edge(from: 2, to: 3))
        graph.add(edge: DirectedGraph<Int>.Edge(from: 4, to: 5))

        let components = graph.connectedComponentsOfEdges()

        // Should work with directed graphs too via the protocol
        #expect(components.count >= 1)

        let totalEdges = components.flatMap(\.self).count
        #expect(totalEdges <= 3) // Should not exceed the number of edges we added
    }

    @Test("Handles duplicate vertices correctly")
    func testHandlesDuplicateVertices() {
        var graph = UndirectedGraph<String>()

        // Add same vertex multiple times
        graph.add(vertex: "A")
        graph.add(vertex: "A")
        graph.add(vertex: "B")

        graph.add(edge: UndirectedGraph<String>.Edge(from: "A", to: "B"))

        let components = graph.connectedComponentsOfEdges()

        #expect(components.count == 1)
        #expect(components[0].count == 1) // One edge
    }

    @Test("Large connected component")
    func testLargeConnectedComponent() {
        var graph = UndirectedGraph<Int>()

        // Create a path with many vertices: 1-2-3-...-10
        for i in 1...9 {
            graph.add(edge: UndirectedGraph<Int>.Edge(from: i, to: i + 1))
        }

        let components = graph.connectedComponentsOfEdges()

        #expect(components.count == 1)
        #expect(components[0].count == 9) // 9 edges connecting 10 vertices
    }
}
