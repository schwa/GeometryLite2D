import DemoKit
import Geometry
import SwiftUI
import Visualization
import Interaction

// MARK: -

struct IntersectionDemoView: DemoView {
    static var metadata = DemoMetadata(
        type: Self.self,
        description: "Interactive intersection detection between line segments and circles",
        keywords: ["intersection", "geometry", "interactive"]
    )

    init() {}

    @State
    private var elements: [Identified<UUID, Shape>] = [
        .init(id: .init(), value: .lineSegment(LineSegment(start: CGPoint(x: 100, y: 100), end: CGPoint(x: 250, y: 100)))),
        .init(id: .init(), value: .lineSegment(LineSegment(start: CGPoint(x: 100, y: 100), end: CGPoint(x: 150, y: 150)))),
        .init(id: .init(), value: .circle(Circle_(center: CGPoint(x: 150, y: 150), radius: 50))),
        .init(id: .init(), value: .circle(Circle_(center: CGPoint(x: 250, y: 150), radius: 50)))
    ]

    @State
    private var intersections: [Intersection<CGFloat, CGFloat>] = []

    var body: some View {
        ZStack {
            VisualizationCanvas(elements: elements)
            InteractiveCanvas(elements: $elements, id: \.id)
            Canvas { context, _ in
                for intersection in intersections {
                    switch intersection {
                    case .none(let closest, let separation, let relation):
                        if let closest {
                            context.stroke(Path.saltire(in: CGRect(center: closest.a, size: CGSize(width: 6, height: 6))), with: .color(.red), lineWidth: 2)
                            context.stroke(Path.saltire(in: CGRect(center: closest.b, size: CGSize(width: 6, height: 6))), with: .color(.red), lineWidth: 2)
                            context.stroke(Path(start: closest.a, end: closest.b), with: .color(.red), style: .init(lineWidth: 1, dash: [4, 4]))
                        }

                    case .finite(let hits, let spans, let relation):
                        for hit in hits {
                            let point = hit.point
                            context.stroke(Path.saltire(in: CGRect(center: point, size: CGSize(width: 6, height: 6))), with: .color(.red), lineWidth: 2)
                        }

                    case .infinite(let overlap, let relation):
                        break
                    }
                }
            }
            .allowsHitTesting(false)
        }
        .inspector(isPresented: .constant(true)) {
            List(Array(intersections.enumerated()), id: \.offset) { _, intersection in
                Text("\(intersection)")
            }
        }
        .onChange(of: elements, initial: true) {
            intersections = []
            for lhs in elements {
                for rhs in elements where lhs.id != rhs.id {
                    switch (lhs.value, rhs.value) {
                    case (.lineSegment(let segment), .circle(let circle)), (.circle(let circle), .lineSegment(let segment)):
                        intersections.append(intersect(segment, circle))

                    case (.lineSegment(let lhs), .lineSegment(let rhs)):
                        intersections.append(intersect(lhs, rhs))
                    //                    case (.circle(let lhs), .circle(let rhs)):
                    //                        intersections.append(intersect(lhs, rhs))
                    default:
                        break
                    }
                }
            }
        }
    }
}

extension LineSegment: InteractiveRepresentable {
    public enum HandleID: String, Hashable {
        case start, end
    }

    public func makeHandles() -> [InteractiveHandle<HandleID>] {
        [
            InteractiveHandle(id: .start, position: start),
            InteractiveHandle(id: .end, position: end)
        ]
    }

    public mutating func handleDidChange(id: HandleID, handles: inout [HandleID: InteractiveHandle<HandleID>]) {
        guard let handle = handles[id] else { return }

        switch id {
        case .start:
            start = handle.position

        case .end:
            end = handle.position
        }
    }
}

extension Circle_: InteractiveRepresentable {
    public enum HandleID: String, Hashable {
        case center, edge
    }

    public func makeHandles() -> [InteractiveHandle<HandleID>] {
        let edgePoint = CGPoint(x: center.x + radius, y: center.y)
        return [
            InteractiveHandle(id: .center, position: center),
            InteractiveHandle(id: .edge, position: edgePoint)
        ]
    }

    public mutating func handleDidChange(id: HandleID, handles: inout [HandleID: InteractiveHandle<HandleID>]) {
        guard let handle = handles[id] else { return }

        switch id {
        case .center:
            let delta = CGVector(dx: handle.position.x - center.x, dy: handle.position.y - center.y)
            center = handle.position
            // Move edge handle to maintain radius
            if var edgeHandle = handles[.edge] {
                edgeHandle.position.x += delta.dx
                edgeHandle.position.y += delta.dy
                handles[.edge] = edgeHandle
            }

        case .edge:
            // Calculate radius from center to edge handle position
            radius = hypot(handle.position.x - center.x, handle.position.y - center.y)
        }
    }
}

extension Shape: InteractiveRepresentable {
    typealias HandleID = AnyHashable

    func makeHandles() -> [InteractiveHandle<AnyHashable>] {
        switch self {
        case .lineSegment(let segment):
            return segment.makeHandles().map {
                InteractiveHandle(id: AnyHashable($0.id), position: $0.position)
            }

        case .circle(let circle):
            return circle.makeHandles().map {
                InteractiveHandle(id: AnyHashable($0.id), position: $0.position)
            }
        }
    }

    private mutating func delegateHandleChange<T: InteractiveRepresentable>(
        to shape: inout T,
        id: AnyHashable,
        handles: inout [AnyHashable: InteractiveHandle<AnyHashable>],
        then update: (T) -> Shape
    ) {
        guard let typedId = id.base as? T.HandleID else {
            return
        }
        let typedHandles = Dictionary(uniqueKeysWithValues:
                                        handles.compactMap { key, value in
                                            (key.base as? T.HandleID).map { ($0, InteractiveHandle(id: $0, position: value.position)) }
                                        }
        )
        var mutableHandles = typedHandles
        shape.handleDidChange(id: typedId, handles: &mutableHandles)
        let updatedHandles = Dictionary(uniqueKeysWithValues:
                                            mutableHandles.map { (AnyHashable($0.key), InteractiveHandle(id: AnyHashable($0.key), position: $0.value.position)) }
        )
        handles.merge(updatedHandles) { _, new in new }
        self = update(shape)
    }

    mutating func handleDidChange(id: AnyHashable, handles: inout [AnyHashable: InteractiveHandle<AnyHashable>]) {
        switch self {
        case .lineSegment(var segment):
            delegateHandleChange(to: &segment, id: id, handles: &handles) { .lineSegment($0) }

        case .circle(var circle):
            delegateHandleChange(to: &circle, id: id, handles: &handles) { .circle($0) }
        }
    }
}

extension Identified: @retroactive InteractiveRepresentable where Value: InteractiveRepresentable {
    public typealias HandleID = Value.HandleID

    public func makeHandles() -> [InteractiveHandle<Value.HandleID>] {
        value.makeHandles()
    }

    public mutating func handleDidChange(id: Value.HandleID, handles: inout [Value.HandleID: InteractiveHandle<Value.HandleID>]) {
        value.handleDidChange(id: id, handles: &handles)
    }
}
