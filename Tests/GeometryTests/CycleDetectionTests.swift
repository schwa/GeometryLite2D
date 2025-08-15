import CoreGraphics
@testable import Geometry
import Testing

@Suite("Cycle Detection Tests")
struct CycleDetectionTests {
    // MARK: - Graph Building Tests

    @Test("Build graph from edges")
    func testBuildGraphFromEdges() {
        let edges = [("A", "B"), ("B", "C"), ("C", "A")]
        let graph = buildGraph(from: edges)

        #expect(graph["A"]?.contains("B") == true)
        #expect(graph["A"]?.contains("C") == true)
        #expect(graph["B"]?.contains("A") == true)
        #expect(graph["B"]?.contains("C") == true)
        #expect(graph["C"]?.contains("A") == true)
        #expect(graph["C"]?.contains("B") == true)
        #expect(graph.keys.count == 3)
    }

    @Test("Build graph from line segments")
    func testBuildGraphFromLineSegments() {
        let segments = [
            LineSegment(start: CGPoint.zero, end: CGPoint(x: 1, y: 0)),
            LineSegment(start: CGPoint(x: 1, y: 0), end: CGPoint(x: 1, y: 1)),
            LineSegment(start: CGPoint(x: 1, y: 1), end: CGPoint.zero)
        ]

        let graph = buildGraph(from: segments)

        let p1 = CGPoint.zero
        let p2 = CGPoint(x: 1, y: 0)
        let p3 = CGPoint(x: 1, y: 1)

        #expect(graph[p1]?.contains(p2) == true)
        #expect(graph[p1]?.contains(p3) == true)
        #expect(graph[p2]?.contains(p1) == true)
        #expect(graph[p2]?.contains(p3) == true)
        #expect(graph[p3]?.contains(p1) == true)
        #expect(graph[p3]?.contains(p2) == true)
        #expect(graph.keys.count == 3)
    }

    @Test("Build graph from empty edges")
    func testBuildGraphFromEmptyEdges() {
        let edges: [(String, String)] = []
        let graph = buildGraph(from: edges)

        #expect(graph.isEmpty)
    }

    @Test("Build graph from single edge")
    func testBuildGraphFromSingleEdge() {
        let edges = [("A", "B")]
        let graph = buildGraph(from: edges)

        #expect(graph["A"]?.contains("B") == true)
        #expect(graph["B"]?.contains("A") == true)
        #expect(graph.keys.count == 2)
    }

    // MARK: - Cycle Detection Tests

    @Test("Find triangle cycle")
    func testFindTriangleCycle() {
        let edges = [("A", "B"), ("B", "C"), ("C", "A")]
        let graph = buildGraph(from: edges)

        let cycles = findAllCycles(in: graph)

        #expect(cycles.count == 1)
        #expect(cycles.first?.count == 3)
        #expect(cycles.first?.contains("A") == true)
        #expect(cycles.first?.contains("B") == true)
        #expect(cycles.first?.contains("C") == true)
    }

    @Test("Find square cycle")
    func testFindSquareCycle() {
        let edges = [("A", "B"), ("B", "C"), ("C", "D"), ("D", "A")]
        let graph = buildGraph(from: edges)

        let cycles = findAllCycles(in: graph)

        #expect(cycles.count == 1)
        #expect(cycles.first?.count == 4)
    }

    @Test("Find no cycles in tree")
    func testNoCyclesInTree() {
        let edges = [("A", "B"), ("B", "C"), ("B", "D")]
        let graph = buildGraph(from: edges)

        let cycles = findAllCycles(in: graph)

        #expect(cycles.isEmpty)
    }

    @Test("Find no cycles in linear chain")
    func testNoCyclesInLinearChain() {
        let edges = [("A", "B"), ("B", "C"), ("C", "D")]
        let graph = buildGraph(from: edges)

        let cycles = findAllCycles(in: graph)

        #expect(cycles.isEmpty)
    }

    @Test("Find multiple cycles")
    func testMultipleCycles() {
        // Two separate triangles
        let edges = [
            ("A", "B"), ("B", "C"), ("C", "A"),  // Triangle 1
            ("D", "E"), ("E", "F"), ("F", "D")   // Triangle 2
        ]
        let graph = buildGraph(from: edges)

        let cycles = findAllCycles(in: graph)

        #expect(cycles.count == 2)

        // Both cycles should be length 3
        for cycle in cycles {
            #expect(cycle.count == 3)
        }
    }

    @Test("Find cycles with shared vertex")
    func testCyclesWithSharedVertex() {
        // Two triangles sharing a vertex
        let edges = [
            ("A", "B"), ("B", "C"), ("C", "A"),  // Triangle 1
            ("A", "D"), ("D", "E"), ("E", "A")   // Triangle 2 (shares A)
        ]
        let graph = buildGraph(from: edges)

        let cycles = findAllCycles(in: graph)

        #expect(cycles.count == 2)

        // Both cycles should be length 3
        for cycle in cycles {
            #expect(cycle.count == 3)
        }
    }

    @Test("Find pentagon cycle")
    func testPentagonCycle() {
        let edges = [("A", "B"), ("B", "C"), ("C", "D"), ("D", "E"), ("E", "A")]
        let graph = buildGraph(from: edges)

        let cycles = findAllCycles(in: graph)

        #expect(cycles.count == 1)
        #expect(cycles.first?.count == 5)
    }

    @Test("Find no cycles in empty graph")
    func testNoCyclesInEmptyGraph() {
        let graph: SimpleGraph<String> = [:]
        let cycles = findAllCycles(in: graph)

        #expect(cycles.isEmpty)
    }

    @Test("Find no cycles with single vertex")
    func testNoCyclesWithSingleVertex() {
        let graph: SimpleGraph<String> = ["A": []]
        let cycles = findAllCycles(in: graph)

        #expect(cycles.isEmpty)
    }

    @Test("Find no cycles with two vertices")
    func testNoCyclesWithTwoVertices() {
        let edges = [("A", "B")]
        let graph = buildGraph(from: edges)

        let cycles = findAllCycles(in: graph)

        #expect(cycles.isEmpty)
    }

    @Test("Complex graph with mixed cycles")
    func testComplexGraphWithMixedCycles() {
        // A graph with a triangle and a square connected
        let edges = [
            ("A", "B"), ("B", "C"), ("C", "A"),        // Triangle
            ("C", "D"), ("D", "E"), ("E", "F"), ("F", "C") // Square
        ]
        let graph = buildGraph(from: edges)

        let cycles = findAllCycles(in: graph)

        #expect(cycles.count == 2)

        // Should find one 3-cycle and one 4-cycle
        let cycleLengths = cycles.map(\.count).sorted()
        #expect(cycleLengths == [3, 4])
    }

    @Test("Cycle detection with CGPoint vertices")
    func testCycleDetectionWithCGPoints() {
        let p1 = CGPoint.zero
        let p2 = CGPoint(x: 1, y: 0)
        let p3 = CGPoint(x: 0.5, y: 1)

        let segments = [
            LineSegment(start: p1, end: p2),
            LineSegment(start: p2, end: p3),
            LineSegment(start: p3, end: p1)
        ]

        let graph = buildGraph(from: segments)
        let cycles = findAllCycles(in: graph)

        #expect(cycles.count == 1)
        #expect(cycles.first?.count == 3)
        #expect(cycles.first?.contains(p1) == true)
        #expect(cycles.first?.contains(p2) == true)
        #expect(cycles.first?.contains(p3) == true)
    }

    @Test("Large cycle")
    func testLargeCycle() {
        // Create a hexagon
        let vertices = ["A", "B", "C", "D", "E", "F"]
        var edges: [(String, String)] = []

        for i in 0..<vertices.count {
            let from = vertices[i]
            let to = vertices[(i + 1) % vertices.count]
            edges.append((from, to))
        }

        let graph = buildGraph(from: edges)
        let cycles = findAllCycles(in: graph)

        #expect(cycles.count == 1)
        #expect(cycles.first?.count == 6)
    }

    @Test("Graph with self-loops")
    func testGraphWithSelfLoops() {
        var graph: SimpleGraph<String> = [:]
        graph["A"] = ["A", "B"]  // Self-loop and connection to B
        graph["B"] = ["A"]

        let cycles = findAllCycles(in: graph)

        // Self-loops should not be detected as they're not simple cycles of length >= 3
        #expect(cycles.isEmpty)
    }

    @Test("Disconnected components with cycles")
    func testDisconnectedComponentsWithCycles() {
        // Two separate components, each with a cycle
        let edges = [
            ("A", "B"), ("B", "C"), ("C", "A"),  // Component 1
            ("X", "Y"), ("Y", "Z"), ("Z", "X")   // Component 2
        ]
        let graph = buildGraph(from: edges)

        let cycles = findAllCycles(in: graph)

        #expect(cycles.count == 2)
        for cycle in cycles {
            #expect(cycle.count == 3)
        }
    }

    @Test("Normalize cycle consistency")
    func testNormalizeCycleConsistency() {
        // Test that the same cycle is normalized consistently regardless of starting point
        let edges = [("A", "B"), ("B", "C"), ("C", "A")]
        let graph = buildGraph(from: edges)

        let cycles = findAllCycles(in: graph)

        #expect(cycles.count == 1)

        // The cycle should be normalized (start with lexicographically smallest vertex)
        if let cycle = cycles.first {
            #expect(cycle.first == "A") // A is lexicographically first
        }
    }
}
