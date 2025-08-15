import Collections
@testable import Geometry
import Testing

@Suite("UndirectedValuedGraph Tests")
struct UndirectedValuedGraphTests {
    @Test("Initialize empty graph")
    func testEmptyGraph() {
        let graph = UndirectedValuedGraph<String, Int, Double>()
        #expect(graph.vertices.isEmpty)
        #expect(graph.edges.isEmpty)
        #expect(graph.edgeValues.isEmpty)
    }

    @Test("Add vertices with values")
    func testAddVerticesWithValues() {
        var graph = UndirectedValuedGraph<String, Int, Double>()

        let v1 = graph.add(vertex: "A", value: 10)
        let v2 = graph.add(vertex: "B", value: 20)

        #expect(v1 == "A")
        #expect(v2 == "B")
        #expect(graph.vertices.count == 2)
        #expect(graph.vertices.contains("A"))
        #expect(graph.vertices.contains("B"))

        #expect(graph.value(for: "A") == 10)
        #expect(graph.value(for: "B") == 20)
    }

    @Test("Add edges with values")
    func testAddEdgesWithValues() {
        var graph = UndirectedValuedGraph<String, Int, Double>()

        graph.add(vertex: "A", value: 10)
        graph.add(vertex: "B", value: 20)

        let edge = UndirectedValuedGraph<String, Int, Double>.Edge(from: "A", to: "B")
        let addedEdge = graph.add(edge: edge, value: 5.5)

        #expect(addedEdge.from == "A")
        #expect(addedEdge.to == "B")
        #expect(graph.edges.count == 1)
        #expect(graph.value(for: edge) == 5.5)

        // In undirected graph, both directions should work
        #expect(graph.neighbors(of: "A").contains("B"))
        #expect(graph.neighbors(of: "B").contains("A"))
    }

    @Test("Update vertex value")
    func testUpdateVertexValue() {
        var graph = UndirectedValuedGraph<String, Int, Double>()

        graph.add(vertex: "A", value: 10)
        #expect(graph.value(for: "A") == 10)

        graph.update(value: 15, for: "A")
        #expect(graph.value(for: "A") == 15)
    }

    @Test("Update value for non-existent vertex")
    func testUpdateValueForNonExistentVertex() {
        var graph = UndirectedValuedGraph<String, Int, Double>()

        graph.update(value: 99, for: "NonExistent")
        #expect(graph.value(for: "NonExistent") == 99)
    }

    @Test("Remove vertex removes edges and values")
    func testRemoveVertex() {
        var graph = UndirectedValuedGraph<Int, String, Double>()

        graph.add(vertex: 1, value: "One")
        graph.add(vertex: 2, value: "Two")
        graph.add(vertex: 3, value: "Three")

        let edge1 = UndirectedValuedGraph<Int, String, Double>.Edge(from: 1, to: 2)
        let edge2 = UndirectedValuedGraph<Int, String, Double>.Edge(from: 2, to: 3)

        graph.add(edge: edge1, value: 1.5)
        graph.add(edge: edge2, value: 2.5)

        #expect(graph.vertices.count == 3)
        #expect(graph.edges.count == 2)
        #expect(graph.edgeValues.count == 2)

        graph.remove(vertex: 2)

        #expect(graph.vertices.count == 2)
        #expect(!graph.vertices.contains(2))
        #expect(graph.value(for: 2) == nil)
        #expect(graph.edges.isEmpty) // Both edges should be removed
        #expect(graph.edgeValues.isEmpty)
    }

    @Test("Remove edge")
    func testRemoveEdge() {
        var graph = UndirectedValuedGraph<String, Int, Double>()

        graph.add(vertex: "A", value: 1)
        graph.add(vertex: "B", value: 2)

        let edge = UndirectedValuedGraph<String, Int, Double>.Edge(from: "A", to: "B")
        graph.add(edge: edge, value: 3.14)

        #expect(graph.edges.count == 1)
        #expect(graph.value(for: edge) == 3.14)

        graph.remove(edge: edge)

        #expect(graph.edges.isEmpty)
        #expect(graph.value(for: edge) == nil)
        #expect(graph.vertices.count == 2) // Vertices should remain
    }

    @Test("Contains vertex and edge")
    func testContainsVertexAndEdge() {
        var graph = UndirectedValuedGraph<Int, String, Double>()

        graph.add(vertex: 42, value: "Answer")
        let edge = UndirectedValuedGraph<Int, String, Double>.Edge(from: 42, to: 24)
        graph.add(edge: edge, value: 1.0)

        #expect(graph.contains(vertex: 42))
        #expect(graph.contains(vertex: 24)) // Should be added automatically
        #expect(!graph.contains(vertex: 99))

        #expect(graph.contains(edge: edge))

        let nonExistentEdge = UndirectedValuedGraph<Int, String, Double>.Edge(from: 42, to: 99)
        #expect(!graph.contains(edge: nonExistentEdge))
    }

    @Test("Edge values property")
    func testEdgeValuesProperty() {
        var graph = UndirectedValuedGraph<String, Int, String>()

        graph.add(vertex: "A", value: 1)
        graph.add(vertex: "B", value: 2)
        graph.add(vertex: "C", value: 3)

        let edge1 = UndirectedValuedGraph<String, Int, String>.Edge(from: "A", to: "B")
        let edge2 = UndirectedValuedGraph<String, Int, String>.Edge(from: "B", to: "C")

        graph.add(edge: edge1, value: "first")
        graph.add(edge: edge2, value: "second")

        let edgeValues = graph.edgeValues
        #expect(edgeValues.count == 2)

        let values = edgeValues.map(\.1)
        #expect(values.contains("first"))
        #expect(values.contains("second"))
    }

    @Test("Modify vertices directly")
    func testModifyVertices() {
        var graph = UndirectedValuedGraph<Int, String, Double>()

        graph.add(vertex: 1, value: "One")
        graph.add(vertex: 2, value: "Two")

        var newVertices = OrderedSet<Int>()
        newVertices.append(3)
        newVertices.append(4)

        graph.vertices = newVertices

        #expect(graph.vertices.count == 2)
        #expect(graph.vertices.contains(3))
        #expect(graph.vertices.contains(4))
        #expect(!graph.vertices.contains(1))
        #expect(!graph.vertices.contains(2))
    }

    @Test("Complex valued graph operations")
    func testComplexValuedGraphOperations() {
        var graph = UndirectedValuedGraph<String, Double, String>()

        // Add vertices with weights
        graph.add(vertex: "Start", value: 0.0)
        graph.add(vertex: "Middle", value: 5.5)
        graph.add(vertex: "End", value: 10.0)

        // Add edges with labels
        let edge1 = UndirectedValuedGraph<String, Double, String>.Edge(from: "Start", to: "Middle")
        let edge2 = UndirectedValuedGraph<String, Double, String>.Edge(from: "Middle", to: "End")

        graph.add(edge: edge1, value: "path1")
        graph.add(edge: edge2, value: "path2")

        // Verify the complete graph structure
        #expect(graph.vertices.count == 3)
        #expect(graph.edges.count == 2)

        #expect(graph.value(for: "Start") == 0.0)
        #expect(graph.value(for: "Middle") == 5.5)
        #expect(graph.value(for: "End") == 10.0)

        #expect(graph.value(for: edge1) == "path1")
        #expect(graph.value(for: edge2) == "path2")

        // Check connectivity
        #expect(graph.neighbors(of: "Start").count == 1)
        #expect(graph.neighbors(of: "Middle").count == 2)
        #expect(graph.neighbors(of: "End").count == 1)
    }

    @Test("Value for non-existent vertex returns nil")
    func testValueForNonExistentVertex() {
        let graph = UndirectedValuedGraph<String, Int, Double>()

        #expect(graph.value(for: "NonExistent") == nil)
    }

    @Test("Value for non-existent edge returns nil")
    func testValueForNonExistentEdge() {
        let graph = UndirectedValuedGraph<String, Int, Double>()

        let edge = UndirectedValuedGraph<String, Int, Double>.Edge(from: "A", to: "B")
        #expect(graph.value(for: edge) == nil)
    }

    @Test("Type aliases work correctly")
    func testTypeAliases() {
        let graph = UndirectedValuedGraph<Int, String, Double>()

        // These should compile without issues
        let _: UndirectedValuedGraph<Int, String, Double>.VertexValue = "test"
        let _: UndirectedValuedGraph<Int, String, Double>.EdgeValue = 3.14
        let _: UndirectedValuedGraph<Int, String, Double>.Edge = .init(from: 1, to: 2)
    }
}
