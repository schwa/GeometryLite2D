import SwiftUI
import Geometry
import Visualization

enum Shape {
    case lineSegment(LineSegment)
    case circle(Circle_)
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

    var body: some View {
        ZStack {
            Canvas { context, size in
                for shape in shapes {
                    shape.value.visualize(in: context, style: .init(), transform: .identity)
                }
            }
            ForEach(shapes.enumerated(), id: \.element.id) { offset, shape in
                switch shape.value {
                case .lineSegment(let segment):
                    let segment = Binding {
                        return segment
                    } set: { newValue in
                        shapes[offset].value = .lineSegment(newValue)
                    }
                    DragHandle(position: Binding(
                        get: { segment.wrappedValue.start },
                        set: { segment.wrappedValue.start = $0 }
                    ))
                    DragHandle(position: Binding(
                        get: { segment.wrappedValue.end },
                        set: { segment.wrappedValue.end = $0 }
                    ))
                case .circle(let circle):
                    let circle = Binding {
                        return circle
                    } set: { newValue in
                        shapes[offset].value = .circle(newValue)
                    }
                    DragHandle(position: Binding(
                        get: { circle.wrappedValue.center },
                        set: { circle.wrappedValue.center = $0 }
                    ))
                }
            }
        }
    }
}
