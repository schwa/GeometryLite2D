# ISSUES.md

---

## 1: Rename "Geometry" target to "Geometry2D"

+++
status: new
priority: medium
kind: none
created: 2026-04-21T16:59:39Z
+++

---

## 2: Investigate Thicken thread-safety / shared mutable state

+++
status: new
priority: medium
kind: task
created: 2026-04-25T22:18:50Z
+++

Downstream consumer (Vector, see Vector#3) reports non-deterministic geometry under parallel test execution. Companion to SwiftEarcut#3.

Vector uses Thicken for stroke geometry. Ellipse (a fill) is the main culprit so SwiftEarcut is more suspect, but Quad Curve also occasionally flakes and may exercise Thicken.

Audit Thicken (and any other GeometryLite2D modules used by stroke/fill pipelines) for:
- `static var` declarations.
- Scratch buffers reused across calls.
- Any unsynchronized state.

Repro: see Vector#3 — `for i in (seq 1 20); swift test; end` in Vector fails ~50% of the time on Ellipse, occasionally Quad Curve, under parallel testing; `--no-parallel` is 100% stable.

---

## 3: Voronoi: non-deterministic Delaunay triangulation output

+++
status: new
priority: high
kind: bug
created: 2026-04-26T00:45:19Z
+++

`Sources/Voronoi/DelaunayTriangulation.swift` uses regular `Set`/`Dictionary` for iteration in the Bowyer-Watson loop:

- Line 14: `var triangulation: Set<Triangle>`
- Line 17: `var badTriangles: Set<Triangle>`
- Lines 19, 26, 34: `for triangle in triangulation` / `for triangle in badTriangles` (Set iteration)
- Line 25: `var edgeCount: [UndirectedLineSegment: Int]`
- Line 31: `let polygonEdges = edgeCount.filter { $0.value == 1 }.map(\.key)` — Dictionary iteration order leaks into output
- Line 56: `return Array(triangulation)` — final output array order is non-deterministic

Iteration order is hash-seed-randomized across processes. The output `[Triangle]` order varies run-to-run. Worse: at near-cocircular point configurations, floating-point circumcircle tests can flip which triangles are flagged as 'bad' depending on iteration order, so the output *set* can also vary.

Companion to issue #2. Fix by switching to `OrderedSet`/`OrderedDictionary` (swift-collections, already a dep) for any collection that gets iterated.

---

## 4: Voronoi: non-deterministic edge/site mapping output

+++
status: new
priority: high
kind: bug
created: 2026-04-26T00:45:26Z
+++

`Sources/Voronoi/Voronoi.swift` iterates regular `Dictionary`/`Set` collections where order leaks into output:

- Line 89: `var edgeToTriangles: [EdgeKey: [Int]]`
- Line 111: `for (edgeKey, triangleIndices) in edgeToTriangles` — Dictionary iteration → `voronoiEdges` array order is non-deterministic
- Line 164: `var siteToEdges: [CGPoint: [VoronoiEdge]]`
- Line 167: `var circumcenterToTriangle: [CGPoint: Triangle]` (only used for lookup, OK)
- Line 175: `var associatedSites: Set<CGPoint>`
- Line 192: `for site in associatedSites` — Set iteration → for each edge, the order in which sites get the edge appended to `siteToEdges[site]` varies, so each site's edge list ordering is non-deterministic across processes

Companion to #2 / #GeometryLite2D#3. Fix by using `OrderedDictionary` / `OrderedSet` from swift-collections.

---

## 5: CycleDetection: non-deterministic cycle traversal and output order

+++
status: new
priority: medium
kind: bug
created: 2026-04-26T00:45:36Z
+++

`Sources/GeometryCollections/CycleDetection.swift` has multiple unordered-collection iterations:

- Line 8: `public typealias SimpleGraph<Vertex: Hashable> = [Vertex: Set<Vertex>]` — adjacency stored as Dictionary-of-Sets
- Line 40: `var foundCycles = Set<[Vertex]>()`
- Line 43: `for startVertex in graph.keys` — Dictionary key iteration order varies
- Line 71: `for neighbor in neighbors` — Set iteration in DFS; visit order is non-deterministic
- Line 51: `return Array(validCycles)` — final output array order varies

Cycles themselves are normalized (rotated to canonical start, optionally reversed for winding), so the *set* of cycles found should be stable. Only the output `[[Vertex]]` array order is non-deterministic across processes.

Note: `normalizeCycle` uses `cycle.min(by: { "\($0)" < "\($1)" })` — string-based comparison of `CGPoint` description. That's deterministic per-platform but fragile; consider replacing with a proper `Comparable`-based key.

Companion to #2. Fix by using `OrderedSet`/`OrderedDictionary` for the adjacency and found-cycles set, and sorting neighbors by a stable key before DFS iteration.

---

## 6: Polygon(edges:) walk start non-deterministic

+++
status: new
priority: medium
kind: bug
created: 2026-04-26T00:45:45Z
+++

`Sources/Geometry/Geometries/Polygon+Extensions.swift:209` — `init?(edges: Set<LineSegment>)` starts the polygon walk from `edges.first`. `Set.first` returns a non-deterministic element (hash-seed dependent), so the resulting polygon's vertex rotation/starting point varies across processes.

The convenience overload at line 204 (`init?(edges: some Collection<LineSegment>)`) explicitly converts the input to `Set` before delegating, inheriting the same flake even when the caller passed an ordered collection.

Used by `Polygon.merge(polygons:)` at line 124. If a downstream consumer compares polygons by vertex order (rather than by edge set or normalized form), this surfaces as a flaky test.

Fix options:
1. Take the input as an ordered collection (preserve caller's order) and start the walk from the first edge in input order.
2. After walking, normalize the resulting polygon to a canonical rotation (e.g. rotate so the lexicographically smallest vertex is first).

---
