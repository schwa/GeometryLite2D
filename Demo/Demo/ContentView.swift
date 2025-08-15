import SwiftUI
import Geometry
import Visualization

protocol InteractiveProxy {
    associatedtype Element
    associatedtype Content: View

    @ViewBuilder
    func makeDragHandles(shape: Binding<Element>) -> Content
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

    var makeProxy: (Element) -> any InteractiveProxy

    @State
    var proxies: [ElementID: any InteractiveProxy] = [:]

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
                let proxy = makeProxy(element)
                proxies[id] = proxy
            }
        }
    }

    func dragHandles(for element: Element) -> some View {
        let id = element[keyPath: id]
        if let proxy: any InteractiveProxy = proxies[id] {
            if let index = elements.firstIndex(where: { $0[keyPath: self.id] == id }) {
                let binding = Binding<Element>(
                    get: { elements[index] },
                    set: { elements[index] = $0 }
                )
                proxy.makeDragHandles(shape: binding)
            }
        }
        return EmptyView()
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
            switch element.value {
            case .lineSegment:
                LineSegmentProxy()
            case .circle(let circle):
                CircleProxy(edgePoint: CGPoint(x: circle.center.x + circle.radius, y: circle.center.y))
            }
        }

    }
}

