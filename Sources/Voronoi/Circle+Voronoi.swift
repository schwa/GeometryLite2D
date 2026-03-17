import CoreGraphics
import Geometry

public extension Circle {
    /// Returns true if the circle contains the given point (including on the boundary).
    func contains(_ point: CGPoint) -> Bool {
        let dx = point.x - center.x
        let dy = point.y - center.y
        let distanceSquared = dx * dx + dy * dy
        let squaredRadius = radius * radius
        return distanceSquared < squaredRadius || abs(distanceSquared - squaredRadius) < 1e-8
    }

    /// Creates a circle that passes through three non-collinear points (circumcircle).
    init?(a: CGPoint, b: CGPoint, c: CGPoint) {
        let d = 2 * (a.x * (b.y - c.y) +
                     b.x * (c.y - a.y) +
                     c.x * (a.y - b.y))
        guard abs(d) > 1e-10 else {
            // Points are nearly collinear
            return nil
        }
        let ux = ((a.x * a.x + a.y * a.y) * (b.y - c.y) +
                  (b.x * b.x + b.y * b.y) * (c.y - a.y) +
                  (c.x * c.x + c.y * c.y) * (a.y - b.y)) / d
        let uy = ((a.x * a.x + a.y * a.y) * (c.x - b.x) +
                  (b.x * b.x + b.y * b.y) * (a.x - c.x) +
                  (c.x * c.x + c.y * c.y) * (b.x - a.x)) / d
        let center = CGPoint(x: ux, y: uy)
        let radius = hypot(center.x - a.x, center.y - a.y)
        self.init(center: center, radius: radius)
    }
}
