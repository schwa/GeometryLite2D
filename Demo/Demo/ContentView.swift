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

protocol InteractiveProxy {
    var dragHandles: AnyView { get }
}

struct LineSegmentProxy: InteractiveProxy {
    var shape: Binding<LineSegment>

    var dragHandles: AnyView {
        AnyView(
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
    var shape: Binding<Circle_>
    var edgePoint: CGPoint

    var dragHandles: AnyView {
        AnyView(
            Group {
                DragHandle(position: Binding(
                    get: { shape.wrappedValue.center },
                    set: { shape.wrappedValue.center = $0 }
                ))
//                DragHandle(position: Binding(
//                    get: { shape.wrappedValue.end },
//                    set: { shape.wrappedValue.end = $0 }
//                ))
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
    var shapes: [Identified<UUID, Shape>] = [
        .init(id: .init(), value: .lineSegment(LineSegment(start: CGPoint(x: 100, y: 100), end: CGPoint(x: 250, y: 100)))),
        .init(id: .init(), value:.circle(Circle_(center: CGPoint(x: 150, y: 150), radius: 50))),
        .init(id: .init(), value:.circle(Circle_(center: CGPoint(x: 250, y: 150), radius: 50))),
    ]

    @State
    var proxies: [any InteractiveProxy] = []

    var body: some View {
        ZStack {
            Canvas { context, size in
                for shape in shapes {
                    shape.value.visualize(in: context, style: .init(), transform: .identity)
                }
            }
            ForEach(Array(proxies.enumerated()), id: \.offset) { offset, proxy in
                proxy.dragHandles
            }
        }
        .onChange(of: shapes, initial: true) {
            proxies = shapes.enumerated().map { offset, shape in
                switch shape.value {
                    case .lineSegment:
                    let binding = Binding {
                        guard case .lineSegment(let value) = shapes[offset].value else {
                            fatalError()
                        }
                        return value
                    } set: { newValue in
                        shapes[offset].value = .lineSegment(newValue)
                    }
                    return LineSegmentProxy(shape: binding)
                case .circle:
                    let binding = Binding {
                        guard case .circle(let value) = shapes[offset].value else {
                            fatalError()
                        }
                        return value
                    } set: { newValue in
                        shapes[offset].value = .circle(newValue)
                    }
                    return CircleProxy(shape: binding, edgePoint: .zero)
                }
            }
        }
    }

}

extension Identified: @retroactive Equatable where Value: Equatable {
    public static func == (lhs: Identified, rhs: Identified) -> Bool {
        lhs.id == rhs.id && lhs.value == rhs.value
    }
}
