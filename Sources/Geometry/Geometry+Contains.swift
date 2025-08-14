import CoreGraphics

public extension LineSegment {
    func contains(_ point: CGPoint, within radius: CGFloat) -> Bool {
        let lineVec = end - start
        let pointVec = point - start
        let lineLengthSq = lineVec.lengthSquared
        if lineLengthSq == 0 {
            return (start - point).length <= radius
        }
        let t = max(0, min(1, pointVec.dot(lineVec) / lineLengthSq))
        let projection = start + lineVec * t
        return (projection - point).length <= radius
    }
}

public extension Polygon {
    func contains(_ point: CGPoint) -> Bool {
        var count = 0
        let n = vertices.count
        guard n >= 3 else { return false }

        for i in 0..<n {
            let a = vertices[i]
            let b = vertices[(i + 1) % n]

            // Check if point is on the edge
            if pointIsOnLineSegment(point, a, b) {
                return true
            }

            // Ray-casting: check if the edge crosses a horizontal ray rightward from `point`
            let minY = min(a.y, b.y)
            let maxY = max(a.y, b.y)
            if point.y > minY && point.y <= maxY && point.x <= max(a.x, b.x) {
                let xinters = (point.y - a.y) * (b.x - a.x) / (b.y - a.y + CGFloat.ulpOfOne) + a.x
                if point.x < xinters {
                    count += 1
                }
            }
        }
        return count % 2 == 1
    }

    private func pointIsOnLineSegment(_ p: CGPoint, _ a: CGPoint, _ b: CGPoint) -> Bool {
        let cross = (b.y - a.y) * (p.x - a.x) - (b.x - a.x) * (p.y - a.y)
        if abs(cross) > CGFloat.ulpOfOne {
            return false
        }

        let dot = (p.x - a.x) * (b.x - a.x) + (p.y - a.y) * (b.y - a.y)
        if dot < 0 {
            return false
        }

        let squaredLengthBA = (b.x - a.x) * (b.x - a.x) + (b.y - a.y) * (b.y - a.y)
        if dot > squaredLengthBA {
            return false
        }

        return true
    }
}
