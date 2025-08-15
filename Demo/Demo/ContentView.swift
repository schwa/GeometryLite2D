import SwiftUI
import Geometry
import Visualization

struct ShapeProxy: InteractiveProxy {
    var lineSegmentProxy = LineSegmentProxy()
    var circleProxy: CircleProxy
    
    init(for shape: Shape) {
        if let circle = shape.circle {
            let edgePoint = CGPoint(x: circle.center.x + circle.radius, y: circle.center.y)
            self.circleProxy = CircleProxy(edgePoint: edgePoint)
        } else {
            self.circleProxy = CircleProxy(edgePoint: .zero) // Placeholder
        }
    }

    @ViewBuilder
    func makeDragHandles(shape: Binding<Identified<UUID, Shape>>, proxy: Binding<Self>) -> some View {
        if shape.wrappedValue.value.lineSegment != nil {
            let segment = Binding<LineSegment>(
                get: { shape.wrappedValue.value.lineSegment! },
                set: { shape.wrappedValue.value.lineSegment = $0 }
            )
            let lineProxy = Binding<LineSegmentProxy>(
                get: { proxy.wrappedValue.lineSegmentProxy },
                set: { proxy.wrappedValue.lineSegmentProxy = $0 }
            )
            proxy.wrappedValue.lineSegmentProxy.makeDragHandles(shape: segment, proxy: lineProxy)
        } else if shape.wrappedValue.value.circle != nil {
            let circleBinding = Binding<Circle_>(
                get: { shape.wrappedValue.value.circle! },
                set: { shape.wrappedValue.value.circle = $0 }
            )
            let circleProxyBinding = Binding<CircleProxy>(
                get: { proxy.wrappedValue.circleProxy },
                set: { proxy.wrappedValue.circleProxy = $0 }
            )
            proxy.wrappedValue.circleProxy.makeDragHandles(shape: circleBinding, proxy: circleProxyBinding)
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
