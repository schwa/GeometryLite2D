import CoreGraphics
import Geometry
import Testing

fileprivate extension CGPoint {
    func isApproximatelyEqual(to other: CGPoint, epsilon: CGFloat = 0.0001) -> Bool {
        abs(x - other.x) <= epsilon && abs(y - other.y) <= epsilon
    }
}

@Test func testLineSegmentParallel() {
    let segment = LineSegment(start: .zero, end: CGPoint(x: 4, y: 0))
    let offsetSegment = segment.parallel(by: 2)
    #expect(offsetSegment.start == CGPoint(x: 0, y: 2))
    #expect(offsetSegment.end == CGPoint(x: 4, y: 2))
}

@Test func testLineSegmentSplit() {
    let segment = LineSegment(start: .zero, end: CGPoint(x: 4, y: 0))
    let splits = segment.split(at: CGPoint(x: 2, y: 0))
    #expect(splits.count == 2)
    #expect(splits[0] == LineSegment(start: .zero, end: CGPoint(x: 2, y: 0)))
    #expect(splits[1] == LineSegment(start: CGPoint(x: 2, y: 0), end: CGPoint(x: 4, y: 0)))
    let noSplit = segment.split(at: .zero)
    #expect(noSplit.count == 1)
    #expect(noSplit[0] == segment)
}

@Test func testLineSegmentRemoving() {
    let segment = LineSegment(start: .zero, end: CGPoint(x: 10, y: 0))
    let removeSegment = LineSegment(start: CGPoint(x: 3, y: 0), end: CGPoint(x: 7, y: 0))
    let result = segment.removing(lineSegment: removeSegment)
    #expect(result.count == 2)
    #expect(result[0].start.isApproximatelyEqual(to: .zero))
    #expect(result[0].end.isApproximatelyEqual(to: CGPoint(x: 3, y: 0)))
    #expect(result[1].start.isApproximatelyEqual(to: CGPoint(x: 7, y: 0)))
    #expect(result[1].end.isApproximatelyEqual(to: CGPoint(x: 10, y: 0)))
    let fullRemove = segment.removing(lineSegment: segment)
    #expect(fullRemove.isEmpty)
}

@Test func testLineSegmentRemovingMultiple() {
    let segment = LineSegment(start: .zero, end: CGPoint(x: 10, y: 0))
    let removeSegment1 = LineSegment(start: CGPoint(x: 2, y: 0), end: CGPoint(x: 4, y: 0))
    let removeSegment2 = LineSegment(start: CGPoint(x: 6, y: 0), end: CGPoint(x: 8, y: 0))
    let result = segment.removing(lineSegments: [removeSegment1, removeSegment2])
    #expect(result.count == 3)
    #expect(result[0].start.isApproximatelyEqual(to: .zero))
    #expect(result[0].end.isApproximatelyEqual(to: CGPoint(x: 2, y: 0)))
    #expect(result[1].start.isApproximatelyEqual(to: CGPoint(x: 4, y: 0)))
    #expect(result[1].end.isApproximatelyEqual(to: CGPoint(x: 6, y: 0)))
    #expect(result[2].start.isApproximatelyEqual(to: CGPoint(x: 8, y: 0)))
    #expect(result[2].end.isApproximatelyEqual(to: CGPoint(x: 10, y: 0)))
}

@Test func testLineSegmentSharesVertexAndTJunction() {
    let segment1 = LineSegment(start: .zero, end: CGPoint(x: 4, y: 0))
    let segment2 = LineSegment(start: CGPoint(x: 4, y: 0), end: CGPoint(x: 4, y: 3))
    let segment3 = LineSegment(start: CGPoint(x: 2, y: 0), end: CGPoint(x: 2, y: 2))
    #expect(segment1.sharesVertex(with: segment2))
    #expect(!segment1.sharesVertex(with: segment3))
    #expect(segment1.isTJunction(with: segment3))
    #expect(!segment1.isTJunction(with: segment2))
}

@Test func testLineSegmentReversedAndSorted() {
    let segment = LineSegment(start: CGPoint(x: 1, y: 2), end: CGPoint(x: 3, y: 4))
    let reversedSegment = segment.reversed()
    #expect(reversedSegment.start == segment.end)
    #expect(reversedSegment.end == segment.start)
    let sortedSegment = reversedSegment.sorted()
    #expect(sortedSegment.start < sortedSegment.end)
}
