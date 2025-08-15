import SwiftUI
import Geometry
import Visualization

struct ShapeProxy: InteractiveProxy {
    var lineSegmentProxy = LineSegmentProxy()
    var circleProxy: CircleProxy
    
    init(for shape: Shape) {
        switch shape {
        case .lineSegment:
            self.circleProxy = CircleProxy(edgePoint: .zero) // Placeholder
        case .circle(let circle):
            let edgePoint = CGPoint(x: circle.center.x + circle.radius, y: circle.center.y)
            self.circleProxy = CircleProxy(edgePoint: edgePoint)
        }
    }
    
    func makeDragHandles(shape: Binding<Identified<UUID, Shape>>, proxy: Binding<Self>) -> some View {
        switch shape.wrappedValue.value {
        case .lineSegment:
            let segment = Binding<LineSegment>(
                get: {
                    guard case .lineSegment(let segment) = shape.wrappedValue.value else {
                        fatalError("Shape type mismatch")
                    }
                    return segment
                },
                set: { shape.wrappedValue.value = .lineSegment($0) }
            )
            let lineProxy = Binding<LineSegmentProxy>(
                get: { proxy.wrappedValue.lineSegmentProxy },
                set: { proxy.wrappedValue.lineSegmentProxy = $0 }
            )
            return AnyView(proxy.wrappedValue.lineSegmentProxy.makeDragHandles(shape: segment, proxy: lineProxy))

        case .circle:
            let circleBinding = Binding<Circle_>(
                get: {
                    guard case .circle(let circle) = shape.wrappedValue.value else {
                        fatalError("Shape type mismatch")
                    }
                    return circle
                },
                set: { shape.wrappedValue.value = .circle($0) }
            )
            let circleProxyBinding = Binding<CircleProxy>(
                get: { proxy.wrappedValue.circleProxy },
                set: { proxy.wrappedValue.circleProxy = $0 }
            )
            return AnyView(proxy.wrappedValue.circleProxy.makeDragHandles(shape: circleBinding, proxy: circleProxyBinding))
        }
    }
}

struct ContentView: View {
    @State
    var elements: [Identified<UUID, Shape>] = [
        .init(id: .init(), value: .lineSegment(LineSegment(start: CGPoint(x: 100, y: 100), end: CGPoint(x: 250, y: 100)))),
        .init(id: .init(), value:.circle(Circle_(center: CGPoint(x: 150, y: 150), radius: 50))),
        .init(id: .init(), value:.circle(Circle_(center: CGPoint(x: 250, y: 150), radius: 50))),
    ]

    var body: some View {
        InteractiveCanvas(elements: $elements, id: \.id) { element in
            AnyInteractiveProxy(ShapeProxy(for: element.value))
        }
    }
}
