import SwiftUI
import Geometry
import Visualization

struct DragHandle: View {
    @Binding
    var position: CGPoint

    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 6, height: 6)
            .padding(2)
            .background {
                Circle()
                    .fill(Color.blue)
            }
            .position(position)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        position = value.location
                    }
            )
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

extension Shape {
    var lineSegment: LineSegment? {
        get {
            guard case .lineSegment(let segment) = self else { return nil }
            return segment
        }
        set {
            guard let newValue = newValue else { return }
            self = .lineSegment(newValue)
        }
    }

    var circle: Circle_? {
        get {
            guard case .circle(let circle) = self else { return nil }
            return circle
        }
        set {
            guard let newValue = newValue else { return }
            self = .circle(newValue)
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

extension Identified where ID == UUID {
    init(value: Value) {
        self.init(id: UUID(), value: value)
    }
}

extension Path {
    static func saltire(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        }
    }

    init(start: CGPoint, end: CGPoint) {
        self.init { path in
            path.move(to: start)
            path.addLine(to: end)
        }
    }
}
