import SwiftUI
import Geometry
import Visualization

enum Shape {
    case lineSegment(LineSegment)
    case circle(Circle_)
}

extension Shape: Equatable {
    static func == (lhs: Shape, rhs: Shape) -> Bool {
        switch (lhs, rhs) {
        case (.lineSegment(let lhs), .lineSegment(let rhs)):
            return lhs == rhs
        case (.circle(let lhs), .circle(let rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
}

extension Shape: VisualizationRepresentable {
    var boundingRect: CGRect {
        switch self {
        case .lineSegment(let segment):
            return segment.boundingRect
        case .circle(let circle):
            return circle.boundingRect
        }
    }

    func visualize(in context: GraphicsContext, style: Visualization.VisualizationStyle, transform: CGAffineTransform) {
        switch self {
        case .lineSegment(let segment):
            segment.visualize(in: context, style: style, transform: transform)
        case .circle(let circle):
            circle.visualize(in: context, style: style, transform: transform)
        }
    }
}

// MARK: -

protocol InteractiveProxy {
    associatedtype Element
    func makeDragHandles(shape: Binding<Element>) -> AnyView
}

struct LineSegmentProxy: InteractiveProxy {
    func makeDragHandles(shape: Binding<Identified<UUID, Shape>>) -> AnyView {
        let shape = Binding<LineSegment> {
            guard case .lineSegment(let value) = shape.wrappedValue.value else {
                fatalError("Expected Circle_ type")
            }
            return value
        } set: { newValue in
            shape.wrappedValue.value = .lineSegment(newValue)
        }
        return AnyView(
            Group {
                DragHandle(position: Binding(
                    get: { shape.wrappedValue.start },
                    set: { shape.wrappedValue.start = $0 }
                ))
                DragHandle(position: Binding(
                    get: { shape.wrappedValue.end },
                    set: { shape.wrappedValue.end = $0 }
                ))
            }
        )
    }
}

struct CircleProxy: InteractiveProxy {
    var edgePoint: CGPoint

    func makeDragHandles(shape: Binding<Identified<UUID, Shape>>) -> AnyView {

        let shape = Binding<Circle_> {
            guard case .circle(let value) = shape.wrappedValue.value else {
                fatalError("Expected Circle_ type")
            }
            return value
        } set: { newValue in
            shape.wrappedValue.value = .circle(newValue)
        }

        return AnyView(
            Group {
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
        )
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
        if let proxy = proxies[id] {
            if let index = elements.firstIndex(where: { $0[keyPath: self.id] == id }) {
                let binding = Binding<Element>(
                    get: { elements[index] },
                    set: { elements[index] = $0 }
                )
                // TODO: need to go from Identified<..., Shape> to Shape
                proxy.makeDragHandles(shape: binding)
            }
        }
        return EmptyView()
    }
}

extension Identified: @retroactive Equatable where Value: Equatable {
    public static func == (lhs: Identified, rhs: Identified) -> Bool {
        lhs.id == rhs.id && lhs.value == rhs.value
    }
}

extension Identified: @retroactive VisualizationRepresentable where Value: VisualizationRepresentable {
    public var boundingRect: CGRect {
        return value.boundingRect
    }

    public func visualize(in context: GraphicsContext, style: Visualization.VisualizationStyle, transform: CGAffineTransform) {
        value.visualize(in: context, style: style, transform: transform)
    }
}
