import CoreGraphics
import Foundation

public struct HalfEdgeMesh<ID: Hashable> {
    // Stable ids
    public struct VertexID: Hashable { public let raw: Int }
    public struct HalfEdgeID: Hashable { public let raw: Int }
    public struct FaceID: Hashable { public let raw: Int }

    public struct Vertex {
        public let id: VertexID
        public let p: CGPoint
        public var edge: HalfEdgeID? // one outgoing
    }

    public struct HalfEdge {
        public let id: HalfEdgeID
        public let origin: VertexID
        public var twin: HalfEdgeID?
        public var next: HalfEdgeID?
        public var prev: HalfEdgeID?
        public var face: FaceID?
        public let segmentID: ID
        // cached angle at origin (radians, [-π, π])
        fileprivate var angle: CGFloat
    }

    public struct Face {
        public let id: FaceID
        public var edge: HalfEdgeID? // any boundary edge
        public var signedArea: CGFloat? // computed after labeling
    }

    public private(set) var vertices: [Vertex] = []
    public private(set) var halfEdges: [HalfEdge] = []
    public private(set) var faces: [Face] = []

    // Build from clean segments (deduped, split at T's)
    public init(segments: [Identified<ID, LineSegment>]) {
        build(from: segments)
    }

    // MARK: - Accessors

    @inlinable public func point(_ v: VertexID) -> CGPoint { vertices[v.raw].p }

    @inlinable public func dest(of e: HalfEdgeID) -> VertexID? {
        guard let t = halfEdges[e.raw].twin else { return nil }
        return halfEdges[t.raw].origin
    }

    // MARK: - Build steps

    private mutating func build(from segments: [Identified<ID, LineSegment>]) {
        // 1) Make vertices (exact point hashing is fine given "clean" data)
        var vIndex: [CGPoint: VertexID] = [:]
        func vID(for p: CGPoint) -> VertexID {
            if let id = vIndex[p] { return id }
            let id = VertexID(raw: vertices.count)
            vertices.append(Vertex(id: id, p: p, edge: nil))
            vIndex[p] = id
            return id
        }

        // 2) Create 2 half-edges per segment (both directions) and link twins
        var pendingTwins: [Composite<VertexID, VertexID>: HalfEdgeID] = [:] // (u,v) -> he(u->v), to find twin(v->u)
        halfEdges.reserveCapacity(segments.count * 2)

        for s in segments {
            let a = vID(for: s.value.start)
            let b = vID(for: s.value.end)
            // dir a->b
            let e0 = HalfEdgeID(raw: halfEdges.count)
            let ang0 = vertices[a.raw].p.angle(to: vertices[b.raw].p)
            halfEdges.append(HalfEdge(id: e0, origin: a, twin: nil, next: nil, prev: nil, face: nil, segmentID: s.id, angle: ang0))
            // dir b->a
            let e1 = HalfEdgeID(raw: halfEdges.count)
            let ang1 = vertices[b.raw].p.angle(to: vertices[a.raw].p)
            halfEdges.append(HalfEdge(id: e1, origin: b, twin: nil, next: nil, prev: nil, face: nil, segmentID: s.id, angle: ang1))

            // set twins
            halfEdges[e0.raw].twin = e1
            halfEdges[e1.raw].twin = e0

            // seed vertex.outgoing if empty
            if vertices[a.raw].edge == nil { vertices[a.raw].edge = e0 }
            if vertices[b.raw].edge == nil { vertices[b.raw].edge = e1 }

            // record for wiring later (optional map; not strictly needed beyond twins)
            pendingTwins[.init(a, b)] = e0
            pendingTwins[.init(b, a)] = e1
        }

        // 3) For each vertex, sort outgoing edges by angle CCW
        var outgoing: [[HalfEdgeID]] = Array(repeating: [], count: vertices.count)
        for he in halfEdges {
            outgoing[he.origin.raw].append(he.id)
        }
        for i in 0..<outgoing.count {
            outgoing[i].sort { halfEdges[$0.raw].angle < halfEdges[$1.raw].angle }
            // Keep a canonical edge on the vertex
            if let first = outgoing[i].first { vertices[i].edge = first }
        }

        // 4) Wire next/prev:
        // For a half-edge e: let t = twin(e). At the destination vertex v = dest(e),
        // find t in outgoing[v] (t is an outgoing edge at v). Then next(e) is the edge
        // that comes immediately AFTER t in CCW order around v (wrapping). This keeps
        // the face on the left as we walk e -> next(e).
        for e in halfEdges.indices {
            guard let twin = halfEdges[e].twin,
                  let v = dest(of: halfEdges[e].id) else { continue }
            let list = outgoing[v.raw]
            if let idx = list.firstIndex(of: twin) {
                let nextIdx = (idx + 1) % list.count
                let ne = list[nextIdx]
                // ⚠️ Skip degenerate successor (would create 2-edge cycle)
                if ne == twin { continue }
                halfEdges[e].next = ne
                halfEdges[ne.raw].prev = halfEdges[e].id
            }
        }

        // 5) Face labeling: traverse unvisited cycles via next pointers
        var faceForEdge: [Bool] = Array(repeating: false, count: halfEdges.count)
        var builtFaces: [Face] = []

        for eIdx in halfEdges.indices {
            if faceForEdge[eIdx] { continue }
            // Try to follow a cycle; if next is missing we skip (open chain)
            var loop: [HalfEdgeID] = []
            var e = halfEdges[eIdx].id
            var ok = true
            // detect and collect the cycle
            var seen = Set<HalfEdgeID>()
            while !seen.contains(e) {
                seen.insert(e)
                loop.append(e)
                guard let n = halfEdges[e.raw].next else { ok = false; break }
                e = n
            }
            guard ok, e == loop.first! else { continue } // not a closed loop

            // Create face
            let fID = FaceID(raw: builtFaces.count)
            // assign face to all edges in loop
            for heID in loop {
                halfEdges[heID.raw].face = fID
                faceForEdge[heID.raw] = true
            }
            var f = Face(id: fID, edge: loop.first, signedArea: nil)

            // compute signed area of the boundary polygon
            var pts: [CGPoint] = []
            pts.reserveCapacity(loop.count)
            for heID in loop {
                let o = halfEdges[heID.raw].origin
                pts.append(vertices[o.raw].p)
            }
            f.signedArea = Polygon(pts).signedArea
            builtFaces.append(f)
        }

        self.faces = builtFaces
    }
}

// MARK: - Convenience

extension HalfEdgeMesh.HalfEdgeID: CustomStringConvertible {
    public var description: String { "H\(raw)" }
}
extension HalfEdgeMesh.VertexID: CustomStringConvertible {
    public var description: String { "V\(raw)" }
}
extension HalfEdgeMesh.FaceID: CustomStringConvertible {
    public var description: String { "F\(raw)" }
}

extension HalfEdgeMesh {
    // MARK: - Validation

    /// Validates the consistency of the half-edge mesh structure
    /// Returns nil if valid, or an error message describing the first issue found
    public func validate() -> String? {
        // Check 1: All vertices should be referenced by at least one half-edge
        var verticesInEdges = Set<VertexID>()
        for edge in halfEdges {
            verticesInEdges.insert(edge.origin)
        }

        for vertex in vertices {
            if !verticesInEdges.contains(vertex.id) {
                return "Vertex \(vertex.id) at \(vertex.p) is not referenced by any half-edge"
            }

            // Also check that if a vertex has an edge pointer, it's valid and originates from this vertex
            if let edgeID = vertex.edge {
                if edgeID.raw >= halfEdges.count {
                    return "Vertex \(vertex.id) has invalid edge reference \(edgeID)"
                }
                if halfEdges[edgeID.raw].origin != vertex.id {
                    return "Vertex \(vertex.id) references edge \(edgeID) which doesn't originate from it"
                }
            }
        }

        // Check 2: Each half-edge should be in at least one face (unless it's a boundary edge)
        // Boundary edges are allowed when both the edge and its twin have no face assignment
        // This happens for dangling edges or open boundaries
        for edge in halfEdges {
            if edge.face == nil {
                // Check if this is a legitimate boundary edge
                if edge.twin == nil {
                    return "Edge \(edge.id) has no face and no twin"
                }
                // Note: It's OK for both an edge and its twin to have no face (open boundary)
                // We just need to ensure the twin relationship is valid (checked later)
            }
        }

        // Check 3: Twin relationships are symmetric
        for edge in halfEdges {
            if let twinID = edge.twin {
                if twinID.raw >= halfEdges.count {
                    return "Edge \(edge.id) has invalid twin reference \(twinID)"
                }
                let twin = halfEdges[twinID.raw]
                if twin.twin != edge.id {
                    return "Edge \(edge.id) has twin \(twinID), but that edge's twin is \(twin.twin?.description ?? "nil")"
                }

                // Twins should have opposite vertices
                if let twinDest = dest(of: edge.id), twin.origin != twinDest {
                    return "Edge \(edge.id) and its twin \(twinID) don't have opposite vertices"
                }
                if let edgeDest = dest(of: twinID), edge.origin != edgeDest {
                    return "Edge \(edge.id) and its twin \(twinID) don't have opposite vertices"
                }
            }
        }

        // Check 4: Next/prev relationships are consistent
        for edge in halfEdges {
            if let nextID = edge.next {
                if nextID.raw >= halfEdges.count {
                    return "Edge \(edge.id) has invalid next reference \(nextID)"
                }
                let next = halfEdges[nextID.raw]
                if next.prev != edge.id {
                    return "Edge \(edge.id) has next \(nextID), but that edge's prev is \(next.prev?.description ?? "nil")"
                }
            }

            if let prevID = edge.prev {
                if prevID.raw >= halfEdges.count {
                    return "Edge \(edge.id) has invalid prev reference \(prevID)"
                }
                let prev = halfEdges[prevID.raw]
                if prev.next != edge.id {
                    return "Edge \(edge.id) has prev \(prevID), but that edge's next is \(prev.next?.description ?? "nil")"
                }
            }
        }

        // Check 5: Face boundaries form closed loops
        for face in faces {
            guard let startEdge = face.edge else {
                return "Face \(face.id) has no boundary edge"
            }

            if startEdge.raw >= halfEdges.count {
                return "Face \(face.id) has invalid edge reference \(startEdge)"
            }

            var visited = Set<HalfEdgeID>()
            var currentEdge = startEdge
            var loopCount = 0
            let maxLoopCount = halfEdges.count + 1 // Prevent infinite loops

            while loopCount < maxLoopCount {
                if visited.contains(currentEdge) {
                    if currentEdge != startEdge {
                        return "Face \(face.id) boundary doesn't form a proper closed loop (revisited \(currentEdge) before returning to start)"
                    }
                    break // Properly closed loop
                }

                visited.insert(currentEdge)
                let edge = halfEdges[currentEdge.raw]

                // Check this edge belongs to this face
                if edge.face != face.id {
                    return "Face \(face.id) references edge \(currentEdge) which belongs to face \(edge.face?.description ?? "nil")"
                }

                guard let nextEdge = edge.next else {
                    return "Face \(face.id) has edge \(currentEdge) with no next pointer (open boundary)"
                }

                currentEdge = nextEdge
                loopCount += 1
            }

            if loopCount >= maxLoopCount {
                return "Face \(face.id) boundary appears to be infinite or malformed"
            }

            if visited.count < 3 {
                return "Face \(face.id) has degenerate boundary with only \(visited.count) edges"
            }
        }

        // Check 6: No edge should reference non-existent faces
        for edge in halfEdges {
            if let faceID = edge.face {
                if faceID.raw >= faces.count {
                    return "Edge \(edge.id) references non-existent face \(faceID)"
                }
            }
        }

        // All checks passed
        return nil
    }

    // MARK: - Face -> polygon(s)

    /// Return the ordered boundary of `face` as points (no holes).
    public func polygon(for face: FaceID) -> [CGPoint] {
        guard let start = faces[face.raw].edge else { return [] }
        return collectLoop(startEdge: start)
    }

    // MARK: - Internals

    private func collectLoop(startEdge: HalfEdgeID) -> [CGPoint] {
        var pts: [CGPoint] = []
        var e = startEdge
        var visited = Set<HalfEdgeID>()
        while !visited.contains(e) {
            visited.insert(e)
            let he = halfEdges[e.raw]
            pts.append(vertices[he.origin.raw].p)
            guard let n = he.next else { break }        // open chain -> not a closed loop
            e = n
        }
        // Must return to start and have at least 3 distinct vertices
        if e != startEdge || pts.count < 3 { return [] }
        return pts
    }
}
