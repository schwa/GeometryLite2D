#if canImport(CoreGraphics)
import CoreGraphics
#else
import Foundation
#endif
import Numerics

// MARK: - Factory Methods

public extension Polygon {
    static var empty: Self {
        Polygon([])
    }
}

// MARK: - Computed Properties

public extension Polygon {
    var segments: [LineSegment] {
        guard vertices.count >= 2 else { return [] }
        return (0..<vertices.count).map { i in
            LineSegment(vertices[i], vertices[(i + 1) % vertices.count])
        }
    }
    
    /// The signed area of the polygon using the shoelace formula.
    /// For simple polygons, a positive area indicates counter-clockwise winding.
    var simpleArea: CGFloat {
        guard vertices.count >= 3 else { return 0 }
        
        var sum: CGFloat = 0
        for i in 0..<vertices.count {
            let current = vertices[i]
            let next = vertices[(i + 1) % vertices.count]
            sum += (current.x * next.y) - (next.x * current.y)
        }
        
        return sum / 2
    }
    
    /// Alias for simpleArea to match the removed GeometryNew code
    var signedArea: CGFloat {
        simpleArea
    }
    
    /// Returns the winding order of the polygon
    var winding: Winding {
        simpleArea >= 0 ? .counterClockwise : .clockwise
    }
}

// MARK: - Validation Methods

public extension Polygon {
    /// Returns `true` if the polygon is simple (does not intersect itself).
    func isSimple(epsilon: CGFloat = 1e-5) -> Bool {
        guard vertices.count >= 3 else { return false }
        for i in 0..<vertices.count {
            let a1 = vertices[i]
            let a2 = vertices[(i + 1) % vertices.count]
            for j in (i + 1)..<vertices.count {
                if abs(i - j) <= 1 || (i == 0 && j == vertices.count - 1) {
                    continue
                }
                let b1 = vertices[j]
                let b2 = vertices[(j + 1) % vertices.count]
                if LineSegment(a1, a2).intersects(LineSegment(b1, b2), absoluteTolerance: epsilon) {
                    return false
                }
            }
        }
        return true
    }
    
    /// Returns `true` if the polygon is convex (all interior angles < 180°).
    var isConvex: Bool {
        guard vertices.count >= 3 else { return false }
        
        var initialSign: Bool?
        for i in 0..<vertices.count {
            let a = vertices[i]
            let b = vertices[(i + 1) % vertices.count]
            let c = vertices[(i + 2) % vertices.count]
            
            let cross = CGPoint.cross(a, b, c)
            
            if cross != 0 {
                let currentSign = cross > 0
                if let sign = initialSign {
                    if sign != currentSign {
                        return false
                    }
                } else {
                    initialSign = currentSign
                }
            }
        }
        
        return true
    }
}

// MARK: - Merge Methods

public extension Polygon {
    /// Attempts to merge polygons by removing shared edges and combining the remaining ones into new polygons.
    ///
    /// This function identifies polygons that share **exact matching edges** (i.e. same two endpoints, possibly reversed)
    /// and merges them by removing those shared edges. The resulting merged polygons are constructed from the remaining edges.
    ///
    /// - Important: Only **exact edge matches** are considered shared. Edges that merely **overlap geometrically** (e.g. partially aligned or intersecting)
    ///   will **not** be treated as shared and will not result in a merge.
    ///
    /// - Parameter polygons: An array of `Polygon` instances to attempt to merge.
    /// - Returns: A new array of polygons, where each polygon is the result of merging any polygons with shared edges.
    @available(*, deprecated, message: "Do not use yet. Unit tests failing.")
    static func merge(polygons: [Polygon]) -> [Polygon] {
        var remaining = polygons
        var merged: [Polygon] = []
        
        while !remaining.isEmpty {
            var base = remaining.removeFirst()
            var didMerge = false
            for i in (0..<remaining.count).reversed() {
                let other = remaining[i]
                let sharedEdges = Set(base.segments).intersection(other.segments)
                if !sharedEdges.isEmpty {
                    let baseEdges = Set(base.segments).subtracting(sharedEdges)
                    let otherEdges = Set(other.segments).subtracting(sharedEdges)
                    let newEdges = baseEdges.union(otherEdges)
                    // Try to form a polygon from the merged edge set
                    if let newPolygon = Polygon(edges: newEdges) {
                        base = newPolygon
                        remaining.remove(at: i)
                        didMerge = true
                    }
                }
            }
            merged.append(base)
            if didMerge {
                // Re-run in case further merges are possible
                return merge(polygons: merged + remaining)
            }
        }
        return merged
    }
}

// MARK: - Initializers from Edges

public extension Polygon {
    init?(edges: some Collection<LineSegment>) {
        let edges = Set(edges)
        self.init(edges: edges)
    }
    
    init?(edges: Set<LineSegment>) {
        guard let start = edges.first else { return nil }
        
        var edgeMap: [CGPoint: [CGPoint]] = [:]
        for edge in edges {
            edgeMap[edge.start, default: []].append(edge.end)
        }
        
        var path: [CGPoint] = [start.start, start.end]
        var usedEdges = Set([start])
        
        while path.first != path.last {
            guard let nextCandidates = edgeMap[path.last!],
                  let next = nextCandidates.first(where: { candidate in
                    let e = LineSegment(path.last!, candidate)
                    return !usedEdges.contains(e)
                  }) else {
                return nil // Cannot complete loop
            }
            
            path.append(next)
            usedEdges.insert(LineSegment(path[path.count - 2], next))
        }
        
        let uniquePoints = Set(path.dropLast())
        if uniquePoints.count < 3 {
            return nil
        }
        
        self = Polygon(Array(path.dropLast()))
    }
}

// MARK: - Simplification

public extension Polygon {
    func simplified(colinearEpsilon: CGFloat = 1e-10, distanceEpsilon: CGFloat = 1e-5) -> Polygon {
        guard vertices.count >= 3 else {
            return self
        }
        
        var result: [CGPoint] = []
        let count = vertices.count
        
        for i in 0..<count {
            let prev = vertices[(i - 1 + count) % count]
            let current = vertices[i]
            let next = vertices[(i + 1) % count]
            
            if let last = result.last, last.distance(to: current).isApproximatelyEqual(to: 0, absoluteTolerance: distanceEpsilon) {
                continue
            }
            
            if CGPoint.areColinear(prev, current, next, absoluteTolerance: colinearEpsilon) {
                continue
            }
            
            result.append(current)
        }
        
        // Cleanup degenerate loop
        if result.count >= 2, result.first!.distance(to: result.last!).isApproximatelyEqual(to: 0, absoluteTolerance: distanceEpsilon) {
            result.removeFirst()
        }
        
        // Only return result if it's still a valid polygon
        if result.count >= 3 {
            return Polygon(result)
        }
        return self
    }
}

// MARK: - Internal Helpers

internal extension Array {
    func rotated() -> [Element] {
        guard let first = self.first else { return [] }
        return dropFirst() + [first]
    }
}