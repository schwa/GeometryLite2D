import Collections
import Geometry
import Testing

@Suite("DirectedGraph Tests")
struct DirectedGraphTests {
    
    @Test("Initialize empty graph")
    func testEmptyGraph() {
        let graph = DirectedGraph<Int>()
        #expect(graph.vertices.isEmpty)
        #expect(graph.edges.isEmpty)
    }
    
    @Test("Add vertices")
    func testAddVertices() {
        var graph = DirectedGraph<String>()
        
        let v1 = graph.add(vertex: "A")
        let v2 = graph.add(vertex: "B")
        let v3 = graph.add(vertex: "C")
        
        #expect(v1 == "A")
        #expect(v2 == "B")
        #expect(v3 == "C")
        #expect(graph.vertices.count == 3)
        #expect(graph.vertices.contains("A"))
        #expect(graph.vertices.contains("B"))
        #expect(graph.vertices.contains("C"))
    }
    
    @Test("Add duplicate vertex")
    func testAddDuplicateVertex() {
        var graph = DirectedGraph<Int>()
        
        graph.add(vertex: 1)
        graph.add(vertex: 1) // Duplicate
        
        #expect(graph.vertices.count == 1)
    }
    
    @Test("Add edges")
    func testAddEdges() {
        var graph = DirectedGraph<Int>()
        
        graph.add(vertex: 1)
        graph.add(vertex: 2)
        graph.add(vertex: 3)
        
        let edge1 = graph.add(edge: DirectedGraph<Int>.Edge(from: 1, to: 2))
        let edge2 = graph.add(edge: DirectedGraph<Int>.Edge(from: 2, to: 3))
        
        #expect(edge1.from == 1)
        #expect(edge1.to == 2)
        #expect(edge2.from == 2)
        #expect(edge2.to == 3)
        #expect(graph.edges.count == 2)
    }
    
    @Test("Add edge with new vertices")
    func testAddEdgeWithNewVertices() {
        var graph = DirectedGraph<String>()
        
        // Adding edge should automatically add vertices
        let edge = graph.add(edge: DirectedGraph<String>.Edge(from: "X", to: "Y"))
        
        #expect(graph.vertices.contains("X"))
        #expect(graph.vertices.contains("Y"))
        #expect(graph.edges.contains(edge))
    }
    
    @Test("Remove vertex")
    func testRemoveVertex() {
        var graph = DirectedGraph<Int>()
        
        graph.add(vertex: 1)
        graph.add(vertex: 2)
        graph.add(vertex: 3)
        graph.add(edge: DirectedGraph<Int>.Edge(from: 1, to: 2))
        graph.add(edge: DirectedGraph<Int>.Edge(from: 2, to: 3))
        
        graph.remove(vertex: 2)
        
        #expect(!graph.vertices.contains(2))
        #expect(graph.vertices.count == 2)
        #expect(graph.edges.count == 0) // Both edges should be removed
    }
    
    @Test("Remove edge")
    func testRemoveEdge() {
        var graph = DirectedGraph<Int>()
        
        graph.add(vertex: 1)
        graph.add(vertex: 2)
        let edge = graph.add(edge: DirectedGraph<Int>.Edge(from: 1, to: 2))
        
        graph.remove(edge: edge)
        
        #expect(!graph.edges.contains(edge))
        #expect(graph.vertices.contains(1)) // Vertices should remain
        #expect(graph.vertices.contains(2))
    }
    
    @Test("Get neighbors")
    func testNeighbors() {
        var graph = DirectedGraph<String>()
        
        graph.add(vertex: "A")
        graph.add(vertex: "B")
        graph.add(vertex: "C")
        graph.add(vertex: "D")
        
        graph.add(edge: DirectedGraph<String>.Edge(from: "A", to: "B"))
        graph.add(edge: DirectedGraph<String>.Edge(from: "A", to: "C"))
        graph.add(edge: DirectedGraph<String>.Edge(from: "B", to: "D"))
        
        let neighborsA = graph.neighbors(of: "A")
        let neighborsB = graph.neighbors(of: "B")
        let neighborsC = graph.neighbors(of: "C")
        let neighborsD = graph.neighbors(of: "D")
        
        #expect(neighborsA.count == 2)
        #expect(neighborsA.contains("B"))
        #expect(neighborsA.contains("C"))
        
        #expect(neighborsB.count == 1)
        #expect(neighborsB.contains("D"))
        
        #expect(neighborsC.count == 0)
        #expect(neighborsD.count == 0)
    }
    
    @Test("Contains vertex")
    func testContainsVertex() {
        var graph = DirectedGraph<Int>()
        
        graph.add(vertex: 42)
        
        #expect(graph.contains(vertex: 42))
        #expect(!graph.contains(vertex: 99))
    }
    
    @Test("Contains edge")
    func testContainsEdge() {
        var graph = DirectedGraph<Int>()
        
        graph.add(vertex: 1)
        graph.add(vertex: 2)
        let edge = graph.add(edge: DirectedGraph<Int>.Edge(from: 1, to: 2))
        
        #expect(graph.contains(edge: edge))
        #expect(!graph.contains(edge: DirectedGraph<Int>.Edge(from: 2, to: 1))) // Directed graph
        #expect(!graph.contains(edge: DirectedGraph<Int>.Edge(from: 1, to: 3)))
    }
    
    @Test("Complex graph operations")
    func testComplexGraph() {
        var graph = DirectedGraph<String>()
        
        // Build a more complex graph
        let vertices = ["Start", "A", "B", "C", "End"]
        for v in vertices {
            graph.add(vertex: v)
        }
        
        graph.add(edge: DirectedGraph<String>.Edge(from: "Start", to: "A"))
        graph.add(edge: DirectedGraph<String>.Edge(from: "Start", to: "B"))
        graph.add(edge: DirectedGraph<String>.Edge(from: "A", to: "C"))
        graph.add(edge: DirectedGraph<String>.Edge(from: "B", to: "C"))
        graph.add(edge: DirectedGraph<String>.Edge(from: "C", to: "End"))
        
        #expect(graph.vertices.count == 5)
        #expect(graph.edges.count == 5)
        
        // Check connectivity
        #expect(graph.neighbors(of: "Start").count == 2)
        #expect(graph.neighbors(of: "C").count == 1)
        #expect(graph.neighbors(of: "End").count == 0)
    }
    
    @Test("Self loop edge")
    func testSelfLoop() {
        var graph = DirectedGraph<Int>()
        
        graph.add(vertex: 1)
        let selfLoop = graph.add(edge: DirectedGraph<Int>.Edge(from: 1, to: 1))
        
        #expect(graph.edges.contains(selfLoop))
        #expect(graph.neighbors(of: 1).contains(1))
    }
}