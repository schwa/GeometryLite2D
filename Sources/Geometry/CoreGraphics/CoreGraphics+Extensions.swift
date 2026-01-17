#if canImport(CoreGraphics)
import CoreGraphics
#else
import Foundation
#endif
import Numerics

#if canImport(Glibc)
import Glibc
#endif

import SwiftUI

public extension CGPoint {
    static func * (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }
    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    static func / (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
    }
    static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func *= (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs * rhs
    }
    static func *= (lhs: inout CGPoint, rhs: CGFloat) {
        lhs = lhs * rhs
    }
    static func /= (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs / rhs
    }
    static func /= (lhs: inout CGPoint, rhs: CGFloat) {
        lhs = lhs / rhs
    }
    static func += (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs + rhs
    }
    static func -= (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs - rhs
    }

    var length: CGFloat {
        hypot(x, y)
    }

    var lengthSquared: CGFloat {
        x * x + y * y
    }

    var normalized: CGPoint {
        self / length
    }

    var perpendicular: CGPoint {
        CGPoint(x: -y, y: x)
    }

    func dot(_ other: CGPoint) -> CGFloat {
        x * other.x + y * other.y
    }

    func cross(_ other: CGPoint) -> CGFloat {
        x * other.y - y * other.x
    }

    func distance(to point: CGPoint) -> CGFloat {
        (self - point).length
    }

    /// Calculate the angle from this point to another point
    func angle(to other: CGPoint) -> CGFloat {
        atan2(other.y - y, other.x - x)
    }
    
    /// Rotates this point around a center point by the given angle
    func rotated(around center: CGPoint, by angle: Angle) -> CGPoint {
        let cosAngle = cos(angle.radians)
        let sinAngle = sin(angle.radians)
        let dx = x - center.x
        let dy = y - center.y
        return CGPoint(
            x: center.x + dx * cosAngle - dy * sinAngle,
            y: center.y + dx * sinAngle + dy * cosAngle
        )
    }

    /// Calculate the distance from this point to a line segment
    func distance(to segment: LineSegment) -> CGFloat {
        let dx = segment.end.x - segment.start.x
        let dy = segment.end.y - segment.start.y
        let lengthSquared = dx * dx + dy * dy

        if lengthSquared == 0 {
            return distance(to: segment.start)
        }

        let dotProduct = (x - segment.start.x) * dx + (y - segment.start.y) * dy
        let t: CGFloat = Swift.max(0, Swift.min(1, dotProduct / lengthSquared))
        let projection = CGPoint(x: segment.start.x + t * dx, y: segment.start.y + t * dy)

        return distance(to: projection)
    }

    static prefix func - (point: CGPoint) -> CGPoint {
        CGPoint(x: -point.x, y: -point.y)
    }

    static func cross(_ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint) -> CGFloat {
        let a = p2.x - p1.x
        let b = p2.y - p1.y
        let c = p3.x - p1.x
        let d = p3.y - p1.y
        return a * d - b * c
    }

    static func areColinear(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint, absoluteTolerance: CGFloat = 1e-6) -> Bool {
        // Compute the area of the triangle formed by the three points using the shoelace formula.
        let area = abs((b.x - a.x) * (c.y - a.y) - (c.x - a.x) * (b.y - a.y))
        return area.isApproximatelyEqual(to: 0, absoluteTolerance: absoluteTolerance)
    }

    static func min(_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint {
        CGPoint(x: Swift.min(lhs.x, rhs.x), y: Swift.min(lhs.y, rhs.y))
    }

    static func max(_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint {
        CGPoint(x: Swift.max(lhs.x, rhs.x), y: Swift.max(lhs.y, rhs.y))
    }
}

extension CGPoint: @retroactive Comparable {
    // Sort order is arbitrarily defined as x, then y
    public static func < (lhs: CGPoint, rhs: CGPoint) -> Bool {
        if lhs.x == rhs.x {
            return lhs.y < rhs.y
        }
        return lhs.x < rhs.x
    }
}

#if targetEnvironment(macCatalyst)
// NOTE: This is for macCatalyst only
extension CGPoint: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}
#endif

// MARK: CGSize

public extension CGSize {
    static func * (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width * rhs.width, height: lhs.height * rhs.height)
    }

    static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }

    static func / (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width / rhs.width, height: lhs.height / rhs.height)
    }

    static func / (lhs: CGSize, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }

    static func min(_ lhs: CGSize, _ rhs: CGSize) -> CGSize {
        CGSize(width: Swift.min(lhs.width, rhs.width), height: Swift.min(lhs.height, rhs.height))
    }

    static func max(_ lhs: CGSize, _ rhs: CGSize) -> CGSize {
        CGSize(width: Swift.max(lhs.width, rhs.width), height: Swift.max(lhs.height, rhs.height))
    }

    static func *= (lhs: inout CGSize, rhs: CGSize) {
        lhs = lhs * rhs
    }

    static func /= (lhs: inout CGSize, rhs: CGSize) {
        lhs = CGSize(width: lhs.width / rhs.width, height: lhs.height / rhs.height)
    }

    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    static prefix func - (size: CGSize) -> CGSize {
        CGSize(width: -size.width, height: -size.height)
    }
    static func += (lhs: inout CGSize, rhs: CGSize) {
        lhs = lhs + rhs
    }
    static func -= (lhs: inout CGSize, rhs: CGSize) {
        lhs = lhs - rhs
    }

    var length: CGFloat {
        hypot(width, height)
    }

    var lengthSquared: CGFloat {
        width * width + height * height
    }

    var normalized: CGSize {
        self / length
    }

    var perpendicular: CGSize {
        CGSize(width: -height, height: width)
    }

    func dot(_ other: CGSize) -> CGFloat {
        width * other.width + height * other.height
    }

    func cross(_ other: CGSize) -> CGFloat {
        width * other.height - height * other.width
    }

    func distance(to other: CGSize) -> CGFloat {
        (self - other).length
    }
}

// MARK: CGVector

public extension CGVector {
    static func * (lhs: CGVector, rhs: CGVector) -> CGVector {
        CGVector(dx: lhs.dx * rhs.dx, dy: lhs.dy * rhs.dy)
    }

    static func / (lhs: CGVector, rhs: CGVector) -> CGVector {
        CGVector(dx: lhs.dx / rhs.dx, dy: lhs.dy / rhs.dy)
    }

    static func + (lhs: CGVector, rhs: CGVector) -> CGVector {
        CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
    }

    static func - (lhs: CGVector, rhs: CGVector) -> CGVector {
        CGVector(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy)
    }

    static func *= (lhs: inout CGVector, rhs: CGVector) {
        lhs = lhs * rhs
    }

    static func /= (lhs: inout CGVector, rhs: CGVector) {
        lhs = lhs / rhs
    }

    static func += (lhs: inout CGVector, rhs: CGVector) {
        lhs = lhs + rhs
    }

    static func -= (lhs: inout CGVector, rhs: CGVector) {
        lhs = lhs - rhs
    }

    static func * (vector: CGVector, scalar: CGFloat) -> CGVector {
        CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
    }
    static func / (vector: CGVector, scalar: CGFloat) -> CGVector {
        CGVector(dx: vector.dx / scalar, dy: vector.dy / scalar)
    }

    static prefix func - (vector: CGVector) -> CGVector {
        CGVector(dx: -vector.dx, dy: -vector.dy)
    }

    var length: CGFloat {
        sqrt(dx * dx + dy * dy)
    }

    var lengthSquared: CGFloat {
        dx * dx + dy * dy
    }

    var normalized: CGVector {
        let len = hypot(dx, dy)
        return len > 0 ? CGVector(dx: dx / len, dy: dy / len) : .zero
    }

    /// 90° counter-clockwise perpendicular vector
    var perpendicular: CGVector {
        CGVector(dx: -dy, dy: dx)
    }

    func dot(_ other: CGVector) -> CGFloat {
        dx * other.dx + dy * other.dy
    }

    func cross(_ other: CGVector) -> CGFloat {
        dx * other.dy - dy * other.dx
    }

    func distance(to other: CGVector) -> CGFloat {
        (self - other).length
    }

    static func min(_ lhs: CGVector, _ rhs: CGVector) -> CGVector {
        CGVector(dx: Swift.min(lhs.dx, rhs.dx), dy: Swift.min(lhs.dy, rhs.dy))
    }

    static func max(_ lhs: CGVector, _ rhs: CGVector) -> CGVector {
        CGVector(dx: Swift.max(lhs.dx, rhs.dx), dy: Swift.max(lhs.dy, rhs.dy))
    }
}

// MARK: Interoperability

public extension CGPoint {
    init(_ size: CGSize) {
        self.init(x: size.width, y: size.height)
    }

    // Interop with CGSize
    static func + (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }
    static func - (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x - rhs.width, y: lhs.y - rhs.height)
    }
    static func * (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x * rhs.width, y: lhs.y * rhs.height)
    }
    static func / (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x / rhs.width, y: lhs.y / rhs.height)
    }
    static func += (lhs: inout CGPoint, rhs: CGSize) {
        lhs = lhs + rhs
    }
    static func -= (lhs: inout CGPoint, rhs: CGSize) {
        lhs = lhs - rhs
    }
    static func *= (lhs: inout CGPoint, rhs: CGSize) {
        lhs = lhs * rhs
    }
    static func /= (lhs: inout CGPoint, rhs: CGSize) {
        lhs = lhs / rhs
    }
}

public extension CGPoint {
    init(_ other: CGVector) {
        self.init(x: other.dx, y: other.dy)
    }

    static func + (lhs: CGPoint, rhs: CGVector) -> CGPoint {
        CGPoint(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy)
    }
    static func - (lhs: CGPoint, rhs: CGVector) -> CGPoint {
        CGPoint(x: lhs.x - rhs.dx, y: lhs.y - rhs.dy)
    }
    static func * (lhs: CGPoint, rhs: CGVector) -> CGPoint {
        CGPoint(x: lhs.x * rhs.dx, y: lhs.y * rhs.dy)
    }
    static func / (lhs: CGPoint, rhs: CGVector) -> CGPoint {
        CGPoint(x: lhs.x / rhs.dx, y: lhs.y / rhs.dy)
    }
    static func += (lhs: inout CGPoint, rhs: CGVector) {
        lhs = lhs + rhs
    }
    static func -= (lhs: inout CGPoint, rhs: CGVector) {
        lhs = lhs - rhs
    }
    static func *= (lhs: inout CGPoint, rhs: CGVector) {
        lhs = lhs * rhs
    }
    static func /= (lhs: inout CGPoint, rhs: CGVector) {
        lhs = lhs / rhs
    }
}

public extension CGVector {
    init(_ point: CGPoint) {
        self.init(dx: point.x, dy: point.y)
    }
    init(_ size: CGSize) {
        self.init(dx: size.width, dy: size.height)
    }
}

public extension CGSize {
    init(_ point: CGPoint) {
        self.init(width: point.x, height: point.y)
    }
    init(_ vector: CGVector) {
        self.init(width: vector.dx, height: vector.dy)
    }
}

// MARK: -

public extension CGRect {
    init(center: CGPoint, radius: CGFloat) {
        self.init(origin: .init(x: center.x - radius, y: center.y - radius), size: .init(width: radius * 2, height: radius * 2))
    }

    init(points: [CGPoint]) {
        guard let first = points.first else {
            self = .null
            return
        }
        self = CGRect(origin: first, size: .zero)
        for point in points.dropFirst() {
            self = self.union(CGRect(origin: point, size: .zero))
        }
    }
}

public func perpendicularPoint(from point: CGPoint, direction: CGVector, distance: CGFloat) -> CGPoint {
    point + direction.normalized.perpendicular * distance
}

public extension CGRect {
    var midXMidY: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}

extension CGPoint: @retroactive ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: CGFloat...) {
        guard elements.count == 2 else {
            fatalError("CGPoint requires exactly 2 elements")
        }
        self.init(x: elements[0], y: elements[1])
    }
}

extension CGSize: @retroactive ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: CGFloat...) {
        guard elements.count == 2 else {
            fatalError("CGSize requires exactly 2 elements")
        }
        self.init(width: elements[0], height: elements[1])
    }
}

extension CGVector: @retroactive ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: CGFloat...) {
        guard elements.count == 2 else {
            fatalError("CGVector requires exactly 2 elements")
        }
        self.init(dx: elements[0], dy: elements[1])
    }
}

public extension CGPoint {
    func angle(relativeTo point: CGPoint) -> Angle {
        let dx = self.x - point.x
        let dy = self.y - point.y
        return Angle(radians: atan2(dy, dx))
    }
}
