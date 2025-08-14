@testable import Geometry
import Testing

@Test
func testAddVertex() {
    var graph = NewGraph<String, Int, String>()
    graph.addVertex("A", value: "Vertex A")

    #expect(graph.vertexValue(for: "A") == "Vertex A")
    #expect(graph.containsVertex("A"))
}

@Test
func testAddEdge() {
    var graph = NewGraph<String, Int, String>()
    graph.addVertex("A", value: "Vertex A")
    graph.addVertex("B", value: "Vertex B")
    graph.addEdge(from: "A", to: "B", value: 10)

    #expect(graph.edgeValue(from: "A", to: "B") == 10)
    #expect(graph.containsEdge(from: "A", to: "B"))
}

@Test
func testNeighbors() {
    var graph = NewGraph<String, Int, String>()
    graph.addVertex("A", value: "Vertex A")
    graph.addVertex("B", value: "Vertex B")
    graph.addEdge(from: "A", to: "B", value: 10)

    #expect(graph.neighbors(of: "A") == ["B"])
}

@Test
func testRemoveEdge() {
    var graph = NewGraph<String, Int, String>()
    graph.addVertex("A", value: "Vertex A")
    graph.addVertex("B", value: "Vertex B")
    graph.addEdge(from: "A", to: "B", value: 10)
    graph.removeEdge(from: "A", to: "B")

    #expect(!graph.containsEdge(from: "A", to: "B"))
}

@Test
func testRemoveVertex() {
    var graph = NewGraph<String, Int, String>()
    graph.addVertex("A", value: "Vertex A")
    graph.addVertex("B", value: "Vertex B")
    graph.addEdge(from: "A", to: "B", value: 10)
    graph.removeVertex("A")
    #expect(!graph.containsVertex("A"))
    #expect(!graph.containsEdge(from: "A", to: "B"))
}

@Test
func testConnectedEdgeComponentsSingleComponent() {
    var graph = NewGraph<String, Int, String>()
    graph.addVertex("A", value: "Vertex A")
    graph.addVertex("B", value: "Vertex B")
    graph.addEdge(from: "A", to: "B", value: 10)

    let components = graph.connectedEdgeComponents()

    #expect(components.count == 1)
    #expect(components[0].count == 1)
    #expect(components[0].contains { $0.from == "A" && $0.to == "B" })
}

@Test
func testConnectedEdgeComponentsMultipleComponents() {
    var graph = NewGraph<String, Int, String>()
    graph.addVertex("A", value: "Vertex A")
    graph.addVertex("B", value: "Vertex B")
    graph.addVertex("C", value: "Vertex C")
    graph.addVertex("D", value: "Vertex D")
    graph.addEdge(from: "A", to: "B", value: 10)
    graph.addEdge(from: "C", to: "D", value: 20)

    let components = graph.connectedEdgeComponents()

    #expect(components.count == 2)
    #expect(components.contains {
        $0.contains { $0.from == "A" && $0.to == "B" }
    })
    #expect(components.contains {
        $0.contains { $0.from == "C" && $0.to == "D" }
    })
}

@Test(.disabled())
func testConnectedEdgeComponentsDisconnectedGraph() {
    var graph = NewGraph<String, Int, String>()
    graph.addVertex("A", value: "Vertex A")
    graph.addVertex("B", value: "Vertex B")
    graph.addVertex("C", value: "Vertex C")

    let components = graph.connectedEdgeComponents()

    #expect(components.count == 3)
//    #expect(components.allSatisfy(\.isEmpty))
}

@Test
func testConnectedEdgeComponentsSingleEdge() {
    var graph = NewGraph<String, Int, String>()
    graph.addVertex("A", value: "Vertex A")
    graph.addVertex("B", value: "Vertex B")
    graph.addEdge(from: "A", to: "B", value: 10)

    let components = graph.connectedEdgeComponents()

    #expect(components.count == 1)
    #expect(components[0].count == 1)
    #expect(components[0].contains { $0.from == "A" && $0.to == "B" })
}

@Test
func testConnectedEdgeComponentsMultipleEdgesSingleComponent() {
    var graph = NewGraph<String, Int, String>()
    graph.addVertex("A", value: "Vertex A")
    graph.addVertex("B", value: "Vertex B")
    graph.addVertex("C", value: "Vertex C")
    graph.addEdge(from: "A", to: "B", value: 10)
    graph.addEdge(from: "B", to: "C", value: 20)

    let components = graph.connectedEdgeComponents()

    #expect(components.count == 1)
    #expect(components[0].count == 2)
    #expect(components[0].contains { $0.from == "A" && $0.to == "B" })
    #expect(components[0].contains { $0.from == "B" && $0.to == "C" })
}

@Test(.disabled())
func testConnectedEdgeComponentsDisconnectedVertices() {
    var graph = NewGraph<String, Int, String>()
    graph.addVertex("A", value: "Vertex A")
    graph.addVertex("B", value: "Vertex B")
    graph.addVertex("C", value: "Vertex C")

    let components = graph.connectedEdgeComponents()

    #expect(components.count == 3)
//    #expect(components.allSatisfy(\.isEmpty))
}

@Test
func testConnectedEdgeComponentsComplexGraph() {
    var graph = NewGraph<String, Int, String>()
    graph.addVertex("A", value: "Vertex A")
    graph.addVertex("B", value: "Vertex B")
    graph.addVertex("C", value: "Vertex C")
    graph.addVertex("D", value: "Vertex D")
    graph.addVertex("E", value: "Vertex E")
    graph.addEdge(from: "A", to: "B", value: 10)
    graph.addEdge(from: "B", to: "C", value: 20)
    graph.addEdge(from: "D", to: "E", value: 30)

    let components = graph.connectedEdgeComponents()

    #expect(components.count == 2)
    #expect(components.contains {
        $0.contains { $0.from == "A" && $0.to == "B" } &&
            $0.contains { $0.from == "B" && $0.to == "C" }
    })
    #expect(components.contains {
        $0.contains { $0.from == "D" && $0.to == "E" }
    })
}

@Test
func testIsConsistentEmptyGraph() {
    let graph = NewGraph<String, Int, String>()
    #expect(graph.isConsistent())
}

@Test
func testIsConsistentValidGraph() {
    var graph = NewGraph<String, Int, String>()
    graph.addVertex("A", value: "Vertex A")
    graph.addVertex("B", value: "Vertex B")
    graph.addEdge(from: "A", to: "B", value: 10)
    #expect(graph.isConsistent())
}

@Test
func testIsConsistentInvalidVertexInAdjacencyList() {
    var graph = NewGraph<String, Int, String>()
    graph.adjacencyList["A"] = ["B"] // Add a vertex without adding it to vertexValues
    #expect(!graph.isConsistent())
}

@Test
func testIsConsistentInvalidEdgeInEdgeValues() {
    var graph = NewGraph<String, Int, String>()
    graph.edgeValues[NewGraph<String, Int, String>.Edge(from: "A", to: "B")] = 10 // Add an edge without valid vertices
    #expect(!graph.isConsistent())
}

@Test
func testIsConsistentInvalidNeighborInAdjacencyList() {
    var graph = NewGraph<String, Int, String>()
    graph.addVertex("A", value: "Vertex A")
    graph.adjacencyList["A"] = ["B"] // Add a neighbor that is not in vertexValues
    #expect(!graph.isConsistent())
}
