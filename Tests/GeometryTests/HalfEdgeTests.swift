import CoreGraphics
import Foundation
import Geometry
import GeometryCollections
import Testing

@Suite("HalfEdge Mesh Tests")
struct HalfEdgeTests {
    @Test("Triangle mesh creation and validation")
    func testTriangle() {
        // Create a simple triangle
        let segments: [Identified<String, LineSegment>] = [
            Identified(id: "AB", value: LineSegment([0, 0], [1, 0])),
            Identified(id: "BC", value: LineSegment([1, 0], [0.5, 1])),
            Identified(id: "CA", value: LineSegment([0.5, 1], [0, 0]))
        ]

        let mesh = HalfEdgeMesh(segments: segments)

        // Validate the mesh structure
        #expect(mesh.validate() == nil, "Mesh should be valid")

        // Check basic counts
        #expect(mesh.vertices.count == 3, "Triangle should have 3 vertices")
        #expect(mesh.halfEdges.count == 6, "Triangle should have 6 half-edges (2 per edge)")
        #expect(mesh.faces.count == 2, "Triangle should have 2 faces (interior and exterior)")

        // Check that each vertex has an outgoing edge
        for vertex in mesh.vertices {
            #expect(vertex.edge != nil, "Vertex \(vertex.id) should have an outgoing edge")
        }

        // Check that all half-edges have twins
        for edge in mesh.halfEdges {
            #expect(edge.twin != nil, "Edge \(edge.id) should have a twin")
        }

        // Check that all half-edges belong to a face
        for edge in mesh.halfEdges {
            #expect(edge.face != nil, "Edge \(edge.id) should belong to a face")
        }
    }

    @Test("Diamond with diagonal - structure and orientation")
    func testDiamondWithDiagonal() {
        // Create a diamond shape with vertices at N, E, S, W
        // and a diagonal connecting N to S, splitting it into two triangles
        let segments: [Identified<String, LineSegment>] = [
            // Diamond perimeter
            Identified(id: "NE", value: LineSegment([0, 1], [1, 0])),    // North to East
            Identified(id: "ES", value: LineSegment([1, 0], [0, -1])),   // East to South
            Identified(id: "SW", value: LineSegment([0, -1], [-1, 0])),  // South to West
            Identified(id: "WN", value: LineSegment([-1, 0], [0, 1])),   // West to North
            // Diagonal splitting the diamond
            Identified(id: "NS", value: LineSegment([0, 1], [0, -1]))    // North to South
        ]

        let mesh = HalfEdgeMesh(segments: segments)

        // === Part 1: Validate basic mesh structure ===
        #expect(mesh.validate() == nil, "Mesh should be valid")

        // Check basic counts
        #expect(mesh.vertices.count == 4, "Diamond should have 4 vertices")
        #expect(mesh.halfEdges.count == 10, "Diamond with diagonal should have 10 half-edges (2 per edge * 5 edges)")
        #expect(mesh.faces.count == 3, "Diamond with diagonal should have 3 faces (2 triangles + exterior)")

        // Check that each vertex has an outgoing edge
        for vertex in mesh.vertices {
            #expect(vertex.edge != nil, "Vertex \(vertex.id) should have an outgoing edge")
        }

        // Check that all half-edges have twins
        for edge in mesh.halfEdges {
            #expect(edge.twin != nil, "Edge \(edge.id) should have a twin")
        }

        // Check that all half-edges belong to a face
        for edge in mesh.halfEdges {
            #expect(edge.face != nil, "Edge \(edge.id) should belong to a face")
        }

        // === Part 2: Verify face identification using orientation ===
        // Interior faces have CW orientation (negative signed area)
        // Exterior face has CCW orientation (positive signed area)

        let interiorFaces = mesh.faces.filter { face in
            if let area = face.signedArea {
                return area < 0  // CW orientation = negative area
            }
            return false
        }

        let exteriorFaces = mesh.faces.filter { face in
            if let area = face.signedArea {
                return area > 0  // CCW orientation = positive area
            }
            return false
        }

        #expect(interiorFaces.count == 2, "Should have 2 interior faces (CW orientation)")
        #expect(exteriorFaces.count == 1, "Should have 1 exterior face (CCW orientation)")

        // Verify the interior faces are triangles with expected area
        for face in interiorFaces {
            if let area = face.signedArea {
                #expect(abs(area) > 0, "Interior face \(face.id) should have non-zero area")
                // For our diamond split diagonally, each triangle should have area 1
                #expect(abs(abs(area) - 1.0) < 0.01, "Interior triangle should have area ≈ 1")
            }
        }

        // === Part 3: Verify orientation consistency ===
        // Collect all faces with their signed areas
        let facesWithSignedAreas = mesh.faces.compactMap { face -> (face: HalfEdgeMesh<String>.Face, signedArea: CGFloat)? in
            guard let area = face.signedArea else { return nil }
            return (face, area)
        }

        // Sort by absolute area to identify exterior (largest) vs interior faces
        let sortedByAbsArea = facesWithSignedAreas.sorted { abs($0.signedArea) > abs($1.signedArea) }

        if sortedByAbsArea.count >= 3 {
            let exteriorSign = sortedByAbsArea[0].signedArea > 0 ? 1 : -1
            let interior1Sign = sortedByAbsArea[1].signedArea > 0 ? 1 : -1
            let interior2Sign = sortedByAbsArea[2].signedArea > 0 ? 1 : -1

            // Interior faces should have the same orientation (same sign)
            #expect(interior1Sign == interior2Sign, "Interior faces should have same orientation")

            // Exterior face should have opposite orientation from interior faces
            #expect(exteriorSign != interior1Sign, "Exterior face should have opposite orientation from interior faces")
        }
    }

    @Test("Triangle with dangling edge")
    func testTriangleWithDanglingEdge() {
        // Create a triangle with an extra segment extending from one vertex
        // This tests how the mesh handles open boundaries
        let segments: [Identified<String, LineSegment>] = [
            // Triangle
            Identified(id: "AB", value: LineSegment([0, 0], [2, 0])),
            Identified(id: "BC", value: LineSegment([2, 0], [1, 2])),
            Identified(id: "CA", value: LineSegment([1, 2], [0, 0])),
            // Dangling edge from vertex A
            Identified(id: "AD", value: LineSegment([0, 0], [-1, -1]))
        ]

        let mesh = HalfEdgeMesh(segments: segments)

        // Validate the mesh structure
        #expect(mesh.validate() == nil, "Mesh should be valid even with dangling edge")

        // Check vertex count - should have 4 vertices (A, B, C, D)
        #expect(mesh.vertices.count == 4, "Should have 4 vertices")

        // Check half-edge count - 4 segments * 2 = 8 half-edges
        #expect(mesh.halfEdges.count == 8, "Should have 8 half-edges")

        // The dangling edge creates an open boundary
        // Some half-edges won't have complete face loops
        let edgesWithoutFacesCount = mesh.halfEdges.filter { $0.face == nil }.count
        // Edges without faces: \(edgesWithoutFacesCount)

        // Count faces - should still detect the triangle face
        let facesWithAreasCount = mesh.faces.filter { $0.signedArea != nil }.count
        // Faces with computed areas: \(facesWithAreasCount)

        // At minimum, we should have the triangle face
        #expect(mesh.faces.count >= 1, "Should have at least the triangle face")

        // Check that vertices still have outgoing edges
        for vertex in mesh.vertices {
            #expect(vertex.edge != nil, "Vertex \(vertex.id) should have an outgoing edge")
        }

        // Check twin relationships are still valid
        for edge in mesh.halfEdges {
            if let twinID = edge.twin {
                let twin = mesh.halfEdges[twinID.raw]
                #expect(twin.twin == edge.id, "Twin relationship should be symmetric")
            }
        }
    }

    @Test("Two triangles sharing a vertex (hourglass)")
    func testHourglassWithSharedVertex() {
        // Create two triangles that share a single vertex at the center (0, 0)
        // This forms an hourglass or bow-tie shape
        let segments: [Identified<String, LineSegment>] = [
            // Top triangle (vertices at center, top-left, top-right)
            Identified(id: "CA", value: LineSegment([0, 0], [-1, 1])),  // Center to top-left
            Identified(id: "AB", value: LineSegment([-1, 1], [1, 1])),  // Top-left to top-right
            Identified(id: "BC", value: LineSegment([1, 1], [0, 0])),   // Top-right to center

            // Bottom triangle (vertices at center, bottom-left, bottom-right)
            Identified(id: "CD", value: LineSegment([0, 0], [-1, -1])), // Center to bottom-left
            Identified(id: "DE", value: LineSegment([-1, -1], [1, -1])), // Bottom-left to bottom-right
            Identified(id: "EC", value: LineSegment([1, -1], [0, 0]))   // Bottom-right to center
        ]

        let mesh = HalfEdgeMesh(segments: segments)

        // Validate the mesh structure
        #expect(mesh.validate() == nil, "Mesh should be valid")

        // Check vertex count - should have 5 vertices (center + 4 corners)
        #expect(mesh.vertices.count == 5, "Should have 5 vertices")

        // Check half-edge count - 6 segments * 2 = 12 half-edges
        #expect(mesh.halfEdges.count == 12, "Should have 12 half-edges")

        // Should have 3 faces (2 triangles + 1 exterior)
        #expect(mesh.faces.count == 3, "Should have 3 faces")

        // Check face orientations using signed area
        let interiorFaces = mesh.faces.filter { face in
            if let area = face.signedArea {
                return area < 0  // CW orientation = negative area
            }
            return false
        }

        let exteriorFaces = mesh.faces.filter { face in
            if let area = face.signedArea {
                return area > 0  // CCW orientation = positive area
            }
            return false
        }

        #expect(interiorFaces.count == 2, "Should have 2 interior faces (the two triangles)")
        #expect(exteriorFaces.count == 1, "Should have 1 exterior face")

        // Verify each triangle has area approximately 1
        for face in interiorFaces {
            if let area = face.signedArea {
                #expect(abs(abs(area) - 1.0) < 0.01, "Each triangle should have area ≈ 1")
            }
        }

        // Check the shared vertex (at origin)
        let centerVertex = mesh.vertices.first { vertex in
            abs(vertex.p.x) < 0.01 && abs(vertex.p.y) < 0.01
        }
        #expect(centerVertex != nil, "Should have a vertex at the center")

        // The center vertex should have multiple outgoing edges (at least 4)
        if let center = centerVertex {
            var outgoingCount = 0
            for edge in mesh.halfEdges {
                if edge.origin == center.id {
                    outgoingCount += 1
                }
            }
            #expect(outgoingCount >= 4, "Center vertex should have at least 4 outgoing edges")
        }
    }

    @Test("Two triangles connected by a bridge segment")
    func testTwoTrianglesWithBridge() {
        // Create two separate triangles and connect them with a bridge segment
        let segments: [Identified<String, LineSegment>] = [
            // Left triangle
            Identified(id: "AB", value: LineSegment([-3, 0], [-1, 0])),   // Bottom edge
            Identified(id: "BC", value: LineSegment([-1, 0], [-2, 2])),   // Right edge
            Identified(id: "CA", value: LineSegment([-2, 2], [-3, 0])),   // Left edge

            // Right triangle
            Identified(id: "DE", value: LineSegment([1, 0], [3, 0])),     // Bottom edge
            Identified(id: "EF", value: LineSegment([3, 0], [2, 2])),     // Right edge
            Identified(id: "FD", value: LineSegment([2, 2], [1, 0])),     // Left edge

            // Bridge segment connecting the two triangles
            Identified(id: "BD", value: LineSegment([-1, 0], [1, 0]))     // Bridge from left triangle to right triangle
        ]

        let mesh = HalfEdgeMesh(segments: segments)

        // Validate the mesh structure
        #expect(mesh.validate() == nil, "Mesh should be valid")

        // Check vertex count - should have 6 vertices (3 per triangle)
        #expect(mesh.vertices.count == 6, "Should have 6 vertices")

        // Check half-edge count - 7 segments * 2 = 14 half-edges
        #expect(mesh.halfEdges.count == 14, "Should have 14 half-edges")

        // The bridge creates a connection but doesn't form new closed faces
        // We should still have 2 triangular faces plus exterior
        #expect(mesh.faces.count == 3, "Should have 3 faces (2 triangles + exterior)")

        // Check face orientations
        let interiorFaces = mesh.faces.filter { face in
            if let area = face.signedArea {
                return area < 0  // CW orientation = negative area
            }
            return false
        }

        let exteriorFaces = mesh.faces.filter { face in
            if let area = face.signedArea {
                return area > 0  // CCW orientation = positive area
            }
            return false
        }

        #expect(interiorFaces.count == 2, "Should have 2 interior faces")
        #expect(exteriorFaces.count == 1, "Should have 1 exterior face")

        // Each triangle should have area = 2 (base=2, height=2, area=2)
        for face in interiorFaces {
            if let area = face.signedArea {
                #expect(abs(abs(area) - 2.0) < 0.01, "Each triangle should have area ≈ 2")
            }
        }

        // Check that the bridge vertices each have at least 3 outgoing edges
        // Vertex at (-1, 0) connects to left triangle and bridge
        let leftBridgeVertex = mesh.vertices.first { vertex in
            abs(vertex.p.x + 1) < 0.01 && abs(vertex.p.y) < 0.01
        }

        // Vertex at (1, 0) connects to right triangle and bridge
        let rightBridgeVertex = mesh.vertices.first { vertex in
            abs(vertex.p.x - 1) < 0.01 && abs(vertex.p.y) < 0.01
        }

        #expect(leftBridgeVertex != nil, "Should have left bridge vertex")
        #expect(rightBridgeVertex != nil, "Should have right bridge vertex")

        // Check connectivity
        if let leftBridge = leftBridgeVertex {
            var outgoingCount = 0
            for edge in mesh.halfEdges {
                if edge.origin == leftBridge.id {
                    outgoingCount += 1
                }
            }
            #expect(outgoingCount >= 3, "Left bridge vertex should have at least 3 outgoing edges")
        }

        if let rightBridge = rightBridgeVertex {
            var outgoingCount = 0
            for edge in mesh.halfEdges {
                if edge.origin == rightBridge.id {
                    outgoingCount += 1
                }
            }
            #expect(outgoingCount >= 3, "Right bridge vertex should have at least 3 outgoing edges")
        }
    }
}
