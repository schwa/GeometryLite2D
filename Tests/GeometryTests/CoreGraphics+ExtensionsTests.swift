import CoreGraphics
import Geometry
import Testing

@Test func testCGPointOperators() {
    let a = CGPoint(x: 3, y: 4)
    let b = CGPoint(x: 1, y: 2)
    #expect(a + b == CGPoint(x: 4, y: 6))
    #expect(a - b == CGPoint(x: 2, y: 2))
    #expect(a * b == CGPoint(x: 3, y: 8))
    #expect(a / b == CGPoint(x: 3, y: 2))
    #expect(a * 2 == CGPoint(x: 6, y: 8))
    #expect(a / 2 == CGPoint(x: 1.5, y: 2))
}

@Test func testCGPointPropertiesAndMethods() {
    let p = CGPoint(x: 3, y: 4)
    #expect(p.length == 5)
    #expect(p.lengthSquared == 25)
    #expect(p.normalized == CGPoint(x: 0.6, y: 0.8))
    #expect(p.perpendicular == CGPoint(x: -4, y: 3))
    let q = CGPoint(x: 1, y: 0)
    #expect(p.dot(q) == 3)
    #expect(p.cross(q) == -4)
    #expect(p.distance(to: q) == hypot(2, 4))
}

@Test func testCGSizeOperators() {
    let a = CGSize(width: 3, height: 4)
    let b = CGSize(width: 1, height: 2)
    #expect(a + b == CGSize(width: 4, height: 6))
    #expect(a - b == CGSize(width: 2, height: 2))
    #expect(a * b == CGSize(width: 3, height: 8))
    #expect(a / b == CGSize(width: 3, height: 2))
    #expect(a * 2 == CGSize(width: 6, height: 8))
    #expect(a / 2 == CGSize(width: 1.5, height: 2))
}

@Test func testCGSizePropertiesAndMethods() {
    let s = CGSize(width: 3, height: 4)
    #expect(s.length == 5)
    #expect(s.lengthSquared == 25)
    #expect(s.normalized == CGSize(width: 0.6, height: 0.8))
    #expect(s.perpendicular == CGSize(width: -4, height: 3))
    let t = CGSize(width: 1, height: 0)
    #expect(s.dot(t) == 3)
    #expect(s.cross(t) == -4)
    #expect(s.distance(to: t) == hypot(2, 4))
}

@Test func testCGVectorOperators() {
    let a = CGVector(dx: 3, dy: 4)
    let b = CGVector(dx: 1, dy: 2)
    #expect(a + b == CGVector(dx: 4, dy: 6))
    #expect(a - b == CGVector(dx: 2, dy: 2))
    #expect(a * b == CGVector(dx: 3, dy: 8))
    #expect(a / b == CGVector(dx: 3, dy: 2))
    #expect(a * 2 == CGVector(dx: 6, dy: 8))
    #expect(a / 2 == CGVector(dx: 1.5, dy: 2))
}

@Test func testCGVectorPropertiesAndMethods() {
    let v = CGVector(dx: 3, dy: 4)
    #expect(v.length == 5)
    #expect(v.lengthSquared == 25)
    #expect(v.normalized == CGVector(dx: 0.6, dy: 0.8))
    #expect(v.perpendicular == CGVector(dx: -4, dy: 3))
    let w = CGVector(dx: 1, dy: 0)
    #expect(v.dot(w) == 3)
    #expect(v.cross(w) == -4)
    #expect(v.distance(to: w) == hypot(2, 4))
}

@Test func testInteroperability() {
    let p = CGPoint(x: 1, y: 2)
    let s = CGSize(width: 3, height: 4)
    let v = CGVector(dx: 5, dy: 6)
    #expect(CGPoint(s) == CGPoint(x: 3, y: 4))
    #expect(CGPoint(v) == CGPoint(x: 5, y: 6))
    #expect(CGSize(p) == CGSize(width: 1, height: 2))
    #expect(CGSize(v) == CGSize(width: 5, height: 6))
    #expect(CGVector(p) == CGVector(dx: 1, dy: 2))
    #expect(CGVector(s) == CGVector(dx: 3, dy: 4))
}

@Test func testColinearAndCross() {
    let a = CGPoint.zero
    let b = CGPoint(x: 1, y: 1)
    let c = CGPoint(x: 2, y: 2)
    #expect(CGPoint.areColinear(a, b, c))
    let d = CGPoint(x: 2, y: 3)
    #expect(!CGPoint.areColinear(a, b, d))
    #expect(CGPoint.cross(a, b, c) == 0)
}

@Test func testCGRectInit() {
    let center = CGPoint(x: 5, y: 5)
    let rect = CGRect(center: center, radius: 2)
    #expect(rect.origin == CGPoint(x: 3, y: 3))
    #expect(rect.size == CGSize(width: 4, height: 4))
    let points = [CGPoint(x: 1, y: 2), CGPoint(x: 3, y: 4)]
    let bounding = CGRect(points: points)
    #expect(bounding.contains(points[0]))
}

@Test func testPerpendicularPoint() {
    let p = CGPoint.zero
    let dir = CGVector(dx: 1, dy: 0)
    let result = perpendicularPoint(from: p, direction: dir, distance: 2)
    #expect(result.x == 0 && result.y == 2)
}

@Test func testCGPointMinMax() {
    let a = CGPoint(x: 1, y: 5)
    let b = CGPoint(x: 3, y: 2)
    #expect(CGPoint.min(a, b) == CGPoint(x: 1, y: 2))
    #expect(CGPoint.max(a, b) == CGPoint(x: 3, y: 5))
}

@Test func testCGSizeMinMax() {
    let a = CGSize(width: 1, height: 5)
    let b = CGSize(width: 3, height: 2)
    #expect(CGSize.min(a, b) == CGSize(width: 1, height: 2))
    #expect(CGSize.max(a, b) == CGSize(width: 3, height: 5))
}

@Test func testCGVectorMinMax() {
    let a = CGVector(dx: 1, dy: 5)
    let b = CGVector(dx: 3, dy: 2)
    #expect(CGVector.min(a, b) == CGVector(dx: 1, dy: 2))
    #expect(CGVector.max(a, b) == CGVector(dx: 3, dy: 5))
}

@Test func testCGPointPrefixMinusAndComparison() {
    let a = CGPoint(x: 2, y: -3)
    #expect(-a == CGPoint(x: -2, y: 3))
    let b = CGPoint(x: 2, y: 1)
    let c = CGPoint(x: 2, y: 2)
    let d = CGPoint(x: 3, y: 0)
    #expect(b < c)
    #expect(c < d)
    #expect(b < d)
}

@Test func testCGSizePrefixMinus() {
    let a = CGSize(width: 2, height: -3)
    #expect(-a == CGSize(width: -2, height: 3))
}

@Test func testCGVectorPrefixMinus() {
    let a = CGVector(dx: 2, dy: -3)
    #expect(-a == CGVector(dx: -2, dy: 3))
}

@Test func testCGPointCompoundAssignmentWithCGSizeAndCGVector() {
    var p = CGPoint(x: 1, y: 2)
    p += CGSize(width: 3, height: 4)
    #expect(p == CGPoint(x: 4, y: 6))
    p -= CGSize(width: 1, height: 1)
    #expect(p == CGPoint(x: 3, y: 5))
    p *= CGSize(width: 2, height: 2)
    #expect(p == CGPoint(x: 6, y: 10))
    p /= CGSize(width: 2, height: 5)
    #expect(p == CGPoint(x: 3, y: 2))
    p += CGVector(dx: 1, dy: 1)
    #expect(p == CGPoint(x: 4, y: 3))
    p -= CGVector(dx: 2, dy: 1)
    #expect(p == CGPoint(x: 2, y: 2))
    p *= CGVector(dx: 2, dy: 3)
    #expect(p == CGPoint(x: 4, y: 6))
    p /= CGVector(dx: 2, dy: 2)
    #expect(p == CGPoint(x: 2, y: 3))
}

@Test func testCGRectPointsEmpty() {
    let bounding = CGRect(points: [])
    #expect(bounding.isNull)
}

@Test func testCGSizeCompoundAssignment() {
    var s = CGSize(width: 2, height: 3)
    s += CGSize(width: 1, height: 2)
    #expect(s == CGSize(width: 3, height: 5))
    s -= CGSize(width: 1, height: 1)
    #expect(s == CGSize(width: 2, height: 4))
    s *= CGSize(width: 2, height: 3)
    #expect(s == CGSize(width: 4, height: 12))
    s /= CGSize(width: 2, height: 4)
    #expect(s == CGSize(width: 2, height: 3))
}

@Test func testCGVectorCompoundAssignment() {
    var v = CGVector(dx: 2, dy: 3)
    v += CGVector(dx: 1, dy: 2)
    #expect(v == CGVector(dx: 3, dy: 5))
    v -= CGVector(dx: 1, dy: 1)
    #expect(v == CGVector(dx: 2, dy: 4))
    v *= CGVector(dx: 2, dy: 3)
    #expect(v == CGVector(dx: 4, dy: 12))
    v /= CGVector(dx: 2, dy: 4)
    #expect(v == CGVector(dx: 2, dy: 3))
}

@Test func testCGSizeScalarOperators() {
    let s = CGSize(width: 2, height: 3)
    #expect(s * 2 == CGSize(width: 4, height: 6))
    #expect(s / 2 == CGSize(width: 1, height: 1.5))
}

@Test func testCGVectorScalarOperators() {
    let v = CGVector(dx: 2, dy: 3)
    #expect(v * 2 == CGVector(dx: 4, dy: 6))
    #expect(v / 2 == CGVector(dx: 1, dy: 1.5))
}

@Test func testCGPointWithCGSizeOperators() {
    let p = CGPoint(x: 2, y: 3)
    let s = CGSize(width: 4, height: 5)
    #expect(p + s == CGPoint(x: 6, y: 8))
    #expect(p - s == CGPoint(x: -2, y: -2))
    #expect(p * s == CGPoint(x: 8, y: 15))
    #expect(p / s == CGPoint(x: 0.5, y: 0.6))
}

@Test func testCGPointWithCGVectorOperators() {
    let p = CGPoint(x: 2, y: 3)
    let v = CGVector(dx: 4, dy: 5)
    #expect(p + v == CGPoint(x: 6, y: 8))
    #expect(p - v == CGPoint(x: -2, y: -2))
    #expect(p * v == CGPoint(x: 8, y: 15))
    #expect(p / v == CGPoint(x: 0.5, y: 0.6))
}

@Test func testConversions() {
    let p = CGPoint(x: 7, y: 8)
    let s = CGSize(p)
    let v = CGVector(p)
    #expect(s == CGSize(width: 7, height: 8))
    #expect(v == CGVector(dx: 7, dy: 8))
    let s2 = CGSize(width: 9, height: 10)
    let p2 = CGPoint(s2)
    let v2 = CGVector(s2)
    #expect(p2 == CGPoint(x: 9, y: 10))
    #expect(v2 == CGVector(dx: 9, dy: 10))
    let v3 = CGVector(dx: 11, dy: 12)
    let p3 = CGPoint(v3)
    let s3 = CGSize(v3)
    #expect(p3 == CGPoint(x: 11, y: 12))
    #expect(s3 == CGSize(width: 11, height: 12))
}

@Test func testCGRectInitCenterRadius() {
    let center = CGPoint(x: 10, y: 20)
    let radius: CGFloat = 5
    let rect = CGRect(center: center, radius: radius)
    #expect(rect.origin == CGPoint(x: 5, y: 15))
    #expect(rect.size == CGSize(width: 10, height: 10))
}

@Test func testCGRectInitPointsSingle() {
    let pt = CGPoint(x: 2, y: 3)
    let rect = CGRect(points: [pt])
    #expect(rect.origin == pt)
    #expect(rect.size == .zero)
}
