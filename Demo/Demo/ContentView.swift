import SwiftUI
import Geometry
import Visualization

protocol InteractiveProxy {
    associatedtype Element
    associatedtype Content: View

    @ViewBuilder
    func makeDragHandles(shape: Binding<Element>) -> Content
}

struct AnyInteractiveProxy<Element> {
    private let _makeDragHandles: (Binding<Element>) -> AnyView

    init<P: InteractiveProxy>(_ proxy: P) where P.Element == Element {
        self._makeDragHandles = { binding in
            AnyView(proxy.makeDragHandles(shape: binding))
        }
    }

    func makeDragHandles(shape: Binding<Element>) -> AnyView {
        _makeDragHandles(shape)
    }
}

struct LineSegmentProxy: InteractiveProxy {
    func makeDragHandles(shape: Binding<LineSegment>) -> some View {
        DragHandle(position: Binding(
            get: { shape.wrappedValue.start },
            set: { shape.wrappedValue.start = $0 }
        ))
        DragHandle(position: Binding(
            get: { shape.wrappedValue.end },
            set: { shape.wrappedValue.end = $0 }
        ))
    }
}

struct CircleProxy: InteractiveProxy {
    var edgePoint: CGPoint

    func makeDragHandles(shape: Binding<Circle_>) -> some View {
        DragHandle(position: Binding(
            get: { shape.wrappedValue.center },
            set: {
                shape.wrappedValue.center = $0
            }
        ))
        DragHandle(position: Binding(
            get: { edgePoint },
            set: { _ in }
        ))
    }
}


struct DragHandle: View {
    @Binding
    var position: CGPoint

    var body: some View {
        Circle()
            .fill(Color.blue)
            .frame(width: 10, height: 10)
            .position(position)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        position = value.location
                    }
            )
    }
}

struct InteractiveCanvas <Element, ElementID>: View where Element: VisualizationRepresentable, ElementID: Hashable {

    @Binding
    var elements: [Element]

    var id: KeyPath<Element, ElementID>

    var makeProxy: (Element) -> AnyInteractiveProxy<Element>

    @State
    var proxies: [ElementID: AnyInteractiveProxy<Element>] = [:]

    var ids : [ElementID] {
        elements.map { $0[keyPath: id] }
    }

    var body: some View {
        ZStack {
            Canvas { context, size in
                for element in elements {
                    element.visualize(in: context, style: .init(), transform: .identity)
                }
            }
            ForEach(elements, id: id) { element in
                dragHandles(for: element)
            }
        }
        .onChange(of: ids, initial: true) {
            for element in elements {
                let id = element[keyPath: id]
                proxies[id] = makeProxy(element)
            }
        }
    }

    @ViewBuilder
    func dragHandles(for element: Element) -> some View {
        let id = element[keyPath: id]
        if let proxy = proxies[id] {
            if let index = elements.firstIndex(where: { $0[keyPath: self.id] == id }) {
                let binding = Binding<Element>(
                    get: { elements[index] },
                    set: { elements[index] = $0 }
                )
                proxy.makeDragHandles(shape: binding)
            }
        }
    }
}

struct ShapeProxy: InteractiveProxy {
    let initialShape: Shape
    
    func makeDragHandles(shape: Binding<Identified<UUID, Shape>>) -> some View {
        switch initialShape {
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
            return AnyView(LineSegmentProxy().makeDragHandles(shape: segment))
            
        case .circle(let circle):
            let circleBinding = Binding<Circle_>(
                get: {
                    guard case .circle(let circle) = shape.wrappedValue.value else {
                        fatalError("Shape type mismatch")
                    }
                    return circle
                },
                set: { shape.wrappedValue.value = .circle($0) }
            )
            let edgePoint = CGPoint(x: circle.center.x + circle.radius, y: circle.center.y)
            return AnyView(CircleProxy(edgePoint: edgePoint).makeDragHandles(shape: circleBinding))
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
            AnyInteractiveProxy(ShapeProxy(initialShape: element.value))
        }
    }
}
