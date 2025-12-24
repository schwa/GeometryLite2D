import Collections
import Geometry
import GeometryCollections
import Testing

@Suite("UndirectedGraph Tests")
struct UndirectedGraphTests {
    @Test("Initialize empty graph")
    func testEmptyGraph() {
        let graph = UndirectedGraph<Int>()
        #expect(graph.vertices.isEmpty)
        #expect(graph.edges.isEmpty)
    }

    @Test("Add vertices")
    func testAddVertices() {
        var graph = UndirectedGraph<String>()

        let v1 = graph.add(vertex: "A")
        let v2 = graph.add(vertex: "B")

        #expect(v1 == "A")
        #expect(v2 == "B")
        #expect(graph.vertices.count == 2)
        #expect(graph.vertices.contains("A"))
        #expect(graph.vertices.contains("B"))
    }

    @Test("Add edges creates bidirectional connection")
    func testAddEdgesBidirectional() {
        var graph = UndirectedGraph<Int>()

        graph.add(vertex: 1)
        graph.add(vertex: 2)

        let edge = graph.add(edge: UndirectedGraph<Int>.Edge(from: 1, to: 2))

        #expect(edge.from == 1)
        #expect(edge.to == 2)

        // In undirected graph, both vertices should be neighbors of each other
        #expect(graph.neighbors(of: 1).contains(2))
        #expect(graph.neighbors(of: 2).contains(1))

        // Should contain edge in both directions
        #expect(graph.contains(edge: UndirectedGraph<Int>.Edge(from: 1, to: 2)))
        #expect(graph.contains(edge: UndirectedGraph<Int>.Edge(from: 2, to: 1)))
    }

    @Test("Edges list doesn't contain duplicates")
    func testEdgesNoDuplicates() {
        var graph = UndirectedGraph<String>()

        graph.add(vertex: "A")
        graph.add(vertex: "B")
        graph.add(vertex: "C")

        graph.add(edge: UndirectedGraph<String>.Edge(from: "A", to: "B"))
        graph.add(edge: UndirectedGraph<String>.Edge(from: "B", to: "C"))

        // Should only have 2 edges, not 4 (no reverse duplicates)
        #expect(graph.edges.count == 2)
    }

    @Test("Remove vertex removes all connected edges")
    func testRemoveVertex() {
        var graph = UndirectedGraph<Int>()

        graph.add(vertex: 1)
        graph.add(vertex: 2)
        graph.add(vertex: 3)

        graph.add(edge: UndirectedGraph<Int>.Edge(from: 1, to: 2))
        graph.add(edge: UndirectedGraph<Int>.Edge(from: 2, to: 3))

        graph.remove(vertex: 2)

        #expect(!graph.vertices.contains(2))
        #expect(graph.vertices.count == 2)
        #expect(graph.edges.isEmpty) // All edges should be removed
        #expect(!graph.neighbors(of: 1).contains(2))
        #expect(!graph.neighbors(of: 3).contains(2))
    }

    @Test("Remove edge removes bidirectional connection")
    func testRemoveEdge() {
        var graph = UndirectedGraph<Int>()

        graph.add(vertex: 1)
        graph.add(vertex: 2)
        let edge = graph.add(edge: UndirectedGraph<Int>.Edge(from: 1, to: 2))

        graph.remove(edge: edge)

        // Should not contain edge in either direction
        #expect(!graph.contains(edge: UndirectedGraph<Int>.Edge(from: 1, to: 2)))
        #expect(!graph.contains(edge: UndirectedGraph<Int>.Edge(from: 2, to: 1)))

        // Vertices should remain
        #expect(graph.vertices.contains(1))
        #expect(graph.vertices.contains(2))

        // But no longer neighbors
        #expect(!graph.neighbors(of: 1).contains(2))
        #expect(!graph.neighbors(of: 2).contains(1))
    }

    @Test("Contains vertex")
    func testContainsVertex() {
        var graph = UndirectedGraph<String>()

        graph.add(vertex: "node")

        #expect(graph.contains(vertex: "node"))
        #expect(!graph.contains(vertex: "missing"))
    }

    @Test("Contains edge in both directions")
    func testContainsEdgeBothDirections() {
        var graph = UndirectedGraph<Int>()

        graph.add(vertex: 1)
        graph.add(vertex: 2)
        graph.add(edge: UndirectedGraph<Int>.Edge(from: 1, to: 2))

        // Should return true for both directions
        #expect(graph.contains(edge: UndirectedGraph<Int>.Edge(from: 1, to: 2)))
        #expect(graph.contains(edge: UndirectedGraph<Int>.Edge(from: 2, to: 1)))
    }

    @Test("Triangle graph")
    func testTriangleGraph() {
        var graph = UndirectedGraph<String>()

        graph.add(vertex: "A")
        graph.add(vertex: "B")
        graph.add(vertex: "C")

        graph.add(edge: UndirectedGraph<String>.Edge(from: "A", to: "B"))
        graph.add(edge: UndirectedGraph<String>.Edge(from: "B", to: "C"))
        graph.add(edge: UndirectedGraph<String>.Edge(from: "C", to: "A"))

        #expect(graph.vertices.count == 3)
        #expect(graph.edges.count == 3)

        // Each vertex should have 2 neighbors
        #expect(graph.neighbors(of: "A").count == 2)
        #expect(graph.neighbors(of: "B").count == 2)
        #expect(graph.neighbors(of: "C").count == 2)

        // Check specific neighbors
        let neighborsA = graph.neighbors(of: "A")
        #expect(neighborsA.contains("B"))
        #expect(neighborsA.contains("C"))
    }

    @Test("Self loop in undirected graph")
    func testSelfLoop() {
        var graph = UndirectedGraph<Int>()

        graph.add(vertex: 1)
        let selfLoop = graph.add(edge: UndirectedGraph<Int>.Edge(from: 1, to: 1))

        #expect(graph.edges.contains(selfLoop))
        #expect(graph.neighbors(of: 1).contains(1))
    }

    @Test("Modify vertices directly")
    func testModifyVertices() {
        var graph = UndirectedGraph<Int>()

        graph.add(vertex: 1)
        graph.add(vertex: 2)

        // Test direct modification
        var newVertices = OrderedSet<Int>()
        newVertices.append(3)
        newVertices.append(4)
        newVertices.append(5)

        graph.vertices = newVertices

        #expect(graph.vertices.count == 3)
        #expect(graph.vertices.contains(3))
        #expect(graph.vertices.contains(4))
        #expect(graph.vertices.contains(5))
        #expect(!graph.vertices.contains(1))
        #expect(!graph.vertices.contains(2))
    }

    @Test("Complete graph K4")
    func testCompleteGraphK4() {
        var graph = UndirectedGraph<Int>()

        // Create complete graph with 4 vertices
        for i in 1...4 {
            graph.add(vertex: i)
        }

        for i in 1...3 {
            for j in (i + 1)...4 {
                graph.add(edge: UndirectedGraph<Int>.Edge(from: i, to: j))
            }
        }

        #expect(graph.vertices.count == 4)
        #expect(graph.edges.count == 6) // K4 has 4*3/2 = 6 edges

        // Each vertex should have 3 neighbors
        for i in 1...4 {
            #expect(graph.neighbors(of: i).count == 3)
        }
    }
}
