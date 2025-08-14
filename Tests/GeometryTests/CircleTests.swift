import CoreGraphics
import Geometry
import Testing

@Test func testCircleInitAndProperties() {
    let center = CGPoint(x: 1, y: 2)
    let radius: CGFloat = 5
    let circle = Circle(center: center, radius: radius)
    #expect(circle.center == center)
    #expect(circle.radius == radius)
}

@Test func testCircleEquality() {
    let c1 = Circle(center: .zero, radius: 1)
    let c2 = Circle(center: .zero, radius: 1)
    let c3 = Circle(center: CGPoint(x: 1, y: 0), radius: 1)
    let c4 = Circle(center: .zero, radius: 2)
    #expect(c1.center == c2.center && c1.radius == c2.radius)
    #expect(c1.center != c3.center || c1.radius != c3.radius)
    #expect(c1.center != c4.center || c1.radius != c4.radius)
}

@Test func testCircleZeroAndNegativeRadius() {
    let zeroRadius = Circle(center: .zero, radius: 0)
    #expect(zeroRadius.radius == 0)
    let negativeRadius = Circle(center: .zero, radius: -1)
    #expect(negativeRadius.radius == -1)
}
