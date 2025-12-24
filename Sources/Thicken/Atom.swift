import CoreGraphics
import SwiftUI

// MARK: - Atom

/// Primitive geometric shapes that can be converted to paths
public enum Atom {
    /// A closed polygon defined by vertices in order
    case polygon(vertices: [CGPoint])

    /// A triangle defined by apex and two other points
    case wedge(apex: CGPoint, p0: CGPoint, p2: CGPoint)

    /// A pie slice: apex → p0 → arc(around arcCenter, to p2) → close
    case pieslice(apex: CGPoint, arcCenter: CGPoint, p0: CGPoint, p2: CGPoint, clockwise: Bool)
}

extension Atom {
    public func toPath() -> Path {
        var path = Path()

        switch self {
        case .polygon(let vertices):
            guard let first = vertices.first else { return path }
            path.move(to: first)
            for vertex in vertices.dropFirst() {
                path.addLine(to: vertex)
            }
            path.closeSubpath()

        case .wedge(let apex, let p0, let p2):
            path.move(to: apex)
            path.addLine(to: p0)
            path.addLine(to: p2)
            path.closeSubpath()

        case .pieslice(let apex, let arcCenter, let p0, let p2, let clockwise):
            let startAngle = atan2(p0.y - arcCenter.y, p0.x - arcCenter.x)
            let endAngle = atan2(p2.y - arcCenter.y, p2.x - arcCenter.x)
            let radius = hypot(p0.x - arcCenter.x, p0.y - arcCenter.y)

            path.move(to: apex)
            path.addLine(to: p0)
            path.addArc(
                center: arcCenter,
                radius: radius,
                startAngle: Angle(radians: startAngle),
                endAngle: Angle(radians: endAngle),
                clockwise: clockwise
            )
            path.closeSubpath()
        }

        return path
    }
}

// MARK: - [Atom] Extensions

extension Array where Element == Atom {
    /// Convert all atoms to triangle paths (fan triangulation for polygons, arc approximation for pieslices)
    /// - Parameter pixelsPerSegment: Target arc segment length in pixels (smaller = smoother arcs)
    public func toTriangles(pixelsPerSegment: CGFloat = 4) -> [Path] {
        var triangles: [Path] = []

        for atom in self {
            switch atom {
            case .polygon(let vertices):
                guard vertices.count >= 3 else { continue }
                // Fan triangulation from first vertex
                let anchor = vertices[0]
                for i in 1..<(vertices.count - 1) {
                    var path = Path()
                    path.move(to: anchor)
                    path.addLine(to: vertices[i])
                    path.addLine(to: vertices[i + 1])
                    path.closeSubpath()
                    triangles.append(path)
                }

            case .wedge(let apex, let p0, let p2):
                // Already a triangle
                var path = Path()
                path.move(to: apex)
                path.addLine(to: p0)
                path.addLine(to: p2)
                path.closeSubpath()
                triangles.append(path)

            case .pieslice(let apex, let arcCenter, let p0, let p2, let clockwise):
                let startAngle = atan2(p0.y - arcCenter.y, p0.x - arcCenter.x)
                let endAngle = atan2(p2.y - arcCenter.y, p2.x - arcCenter.x)
                let radius = hypot(p0.x - arcCenter.x, p0.y - arcCenter.y)

                // Normalize angle difference based on direction
                var angleDiff = endAngle - startAngle
                if clockwise {
                    if angleDiff > 0 { angleDiff -= 2 * .pi }
                } else {
                    if angleDiff < 0 { angleDiff += 2 * .pi }
                }

                let arcLength = radius * abs(angleDiff)
                let segments = Swift.max(1, Int(ceil(arcLength / pixelsPerSegment)))
                let angleStep = angleDiff / CGFloat(segments)

                // Arc triangles fanning from arcCenter
                var prevPoint = p0
                for i in 1...segments {
                    let angle = startAngle + angleStep * CGFloat(i)
                    let nextPoint = CGPoint(
                        x: arcCenter.x + radius * cos(angle),
                        y: arcCenter.y + radius * sin(angle)
                    )

                    var path = Path()
                    path.move(to: arcCenter)
                    path.addLine(to: prevPoint)
                    path.addLine(to: nextPoint)
                    path.closeSubpath()
                    triangles.append(path)

                    prevPoint = nextPoint
                }

                // Add triangles connecting apex to arcCenter (fills V-shaped gap)
                // Skip if apex and arcCenter are the same point
                if apex != arcCenter {
                    var path1 = Path()
                    path1.move(to: apex)
                    path1.addLine(to: p0)
                    path1.addLine(to: arcCenter)
                    path1.closeSubpath()
                    triangles.append(path1)

                    var path2 = Path()
                    path2.move(to: apex)
                    path2.addLine(to: arcCenter)
                    path2.addLine(to: p2)
                    path2.closeSubpath()
                    triangles.append(path2)
                }
            }
        }

        return triangles
    }
}
