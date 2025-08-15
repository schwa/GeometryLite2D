import SwiftUI
import Geometry
import Visualization

struct InteractiveHandle {
    var position: CGPoint
}

protocol InteractiveRepresentable {
    func makeHandles() -> [InteractiveHandle]
}


struct InteractiveCanvas <Element, ElementID>: View where Element: InteractiveRepresentable, ElementID: Hashable {
    @Binding
    var elements: [Element]

    var id: KeyPath<Element, ElementID>

    @State
    var handles: [ElementID: [UUID: InteractiveHandle]] = [:]

    var elementIDs: [ElementID] {
        elements.map { $0[keyPath: id] }
    }

    var body: some View {
        ZStack {
            ForEach(Array(handles), id: \.key) { elementID, handles in
                ForEach(Array(handles), id: \.key) { handleID, handle in

                    let binding = Binding<CGPoint>(
                        get: { handle.position },
                        set: { newPosition in
                            // TODO: ...
                        }
                    )
                    DragHandle(position: binding)
                }
            }
        }
        .onChange(of: elementIDs, initial: true) {
            for (elementID, element) in zip(elementIDs, elements) {
                let handles = element.makeHandles()
                self.handles[elementID] = Dictionary(uniqueKeysWithValues: handles.map { handle in
                    (UUID(), handle)
                })
            }
        }
    }
}

// MARK: -

struct ContentView: View {
    @State
    var elements: [Identified<UUID, Shape>] = [
        .init(id: .init(), value: .lineSegment(LineSegment(start: CGPoint(x: 100, y: 100), end: CGPoint(x: 250, y: 100)))),
//        .init(id: .init(), value:.circle(Circle_(center: CGPoint(x: 150, y: 150), radius: 50))),
//        .init(id: .init(), value:.circle(Circle_(center: CGPoint(x: 250, y: 150), radius: 50))),
    ]

    var body: some View {
        ZStack {
            VisualizationCanvas(elements: elements)
            InteractiveCanvas(elements: $elements, id: \.id)
        }
    }
}

extension LineSegment: InteractiveRepresentable {
    func makeHandles() -> [InteractiveHandle] {
        return [
            InteractiveHandle(position: start),
            InteractiveHandle(position: end),
        ]
    }
}

extension Circle_: InteractiveRepresentable {
    func makeHandles() -> [InteractiveHandle] {
        return [
//            InteractiveHandle(),
//            InteractiveHandle()
        ]
    }
}

extension Shape: InteractiveRepresentable {
    func makeHandles() -> [InteractiveHandle] {
        switch self {
        case .lineSegment(let segment):
            return segment.makeHandles()
        case .circle(let circle):
            return circle.makeHandles()
        }
    }
}

extension Identified: InteractiveRepresentable where Value: InteractiveRepresentable {
    func makeHandles() -> [InteractiveHandle] {
        value.makeHandles()
    }
}

extension Identified where ID == UUID {
    init(value: Value) {
        self.init(id: UUID(), value: value)
    }
}

