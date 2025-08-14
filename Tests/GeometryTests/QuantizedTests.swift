import CoreGraphics
import Geometry
import Testing

@Test func testQuantizedPointBasic() {
    let point = CGPoint(x: 1.23, y: 4.56)
    let tolerance: CGFloat = 0.5
    let quantized = Quantized(point, tolerance: tolerance)
    let expected = CGPoint(x: 1.0, y: 4.5)
    #expect(quantized.quantizedValue == expected)
}

@Test func testQuantizedEquatable() {
    let quantizedA = Quantized(CGPoint(x: 1.1, y: 2.1), tolerance: 1.0)
    let quantizedB = Quantized(CGPoint(x: 1.4, y: 2.4), tolerance: 1.0)
    let quantizedC = Quantized(CGPoint(x: 2.1, y: 2.1), tolerance: 1.0)
    #expect(quantizedA == quantizedB)
    #expect(quantizedA != quantizedC)
}

@Test func testQuantizedHashable() {
    let quantizedA = Quantized(CGPoint(x: 1.1, y: 2.1), tolerance: 1.0)
    let quantizedB = Quantized(CGPoint(x: 1.4, y: 2.4), tolerance: 1.0)
    let quantizedSet: Set = [quantizedA, quantizedB]
    #expect(quantizedSet.count == 1)
}

@Test func testQuantizedDebugDescription() {
    let point = CGPoint(x: 1.23, y: 4.56)
    let quantized = Quantized(point, tolerance: 0.5)
    #expect(quantized.debugDescription == quantized.quantizedValue.debugDescription)
}

@Test func testQuantizePointsFunction() {
    let points = [CGPoint(x: 0.1, y: 0.1), CGPoint(x: 0.4, y: 0.4), CGPoint(x: 1.1, y: 1.1)]
    let tolerance: CGFloat = 0.5
    let (mapping, totalError) = quantize(points: points, tolerance: tolerance)
    #expect(mapping.count == 3)
    #expect(mapping[CGPoint(x: 0.1, y: 0.1)] == CGPoint(x: 0.1, y: 0.1))
    #expect(mapping[CGPoint(x: 0.4, y: 0.4)] == CGPoint(x: 0.4, y: 0.4))
    #expect(mapping[CGPoint(x: 1.1, y: 1.1)] == CGPoint(x: 1.1, y: 1.1))
    #expect(totalError == 0)
}
