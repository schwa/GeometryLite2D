import CoreGraphics

public protocol Quantizable {
    associatedtype Tolerance
    func quantizedValue(tolerance: Tolerance) -> Self
}

public struct Quantized<Value> where Value: Quantizable {
    public let value: Value
    public let tolerance: Value.Tolerance

    public init(_ value: Value, tolerance: Value.Tolerance) {
        self.value = value
        self.tolerance = tolerance
    }

    public var quantizedValue: Value {
        value.quantizedValue(tolerance: tolerance)
    }
}

extension Quantized: Equatable where Value: Equatable, Value.Tolerance: Equatable {
    public static func == (lhs: Quantized, rhs: Quantized) -> Bool {
        lhs.quantizedValue == rhs.quantizedValue
    }
}

extension Quantized: Hashable where Value: Hashable, Value.Tolerance: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(tolerance)
        hasher.combine(quantizedValue)
    }
}

extension Quantized: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(quantizedValue)"
    }
}

// MARK: -

extension CGPoint: Quantizable {
    public func quantizedValue(tolerance: CGFloat) -> CGPoint {
        CGPoint(x: (x / tolerance).rounded() * tolerance, y: (y / tolerance).rounded() * tolerance)
    }
}

public func quantize(points: [CGPoint], tolerance: CGFloat) -> ([CGPoint: CGPoint], CGFloat) {
    let quantizedPoints = points.reduce(into: [Quantized<CGPoint>: [CGPoint]]()) { partialResult, point in
        let quantized = Quantized(point, tolerance: tolerance)
        partialResult[quantized, default: []].append(point)
    }

    let clusteredPoints = Dictionary(quantizedPoints.values.flatMap { points in
        let average = points.reduce(CGPoint.zero) { $0 + $1 } / CGFloat(points.count)
        return points.map { ($0, average) }
    }) { lhs, rhs in
        assert(lhs == rhs)
        return lhs
    }
    let mappedPoints = Dictionary(points.map { point in
        (point, clusteredPoints[point] ?? [])
    }) { first, _ in first }

    let totalError = mappedPoints.reduce(0.0) { partialResult, item in
        let error = item.key.distance(to: item.value)
        return partialResult + error
    }
    return (mappedPoints, totalError)
}
