import SwiftUI
import Geometry
import Visualization

struct InteractiveHandle: Identifiable {
    var id: String
    var position: CGPoint
}

protocol InteractiveRepresentable {
    func makeHandles() -> [InteractiveHandle]
    mutating func handleDidChange(_ handle: InteractiveHandle)
}


struct InteractiveCanvas <Element, ElementID>: View where Element: InteractiveRepresentable, ElementID: Hashable {
    @Binding
    var elements: [Element]

    var id: KeyPath<Element, ElementID>

    @State
    var handles: [ElementID: [InteractiveHandle.ID: InteractiveHandle]] = [:]

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
                            if let elementIndex = elements.firstIndex(where: { $0[keyPath: id] == elementID }) {
                                // Update handle position in state
                                self.handles[elementID]?[handleID]?.position = newPosition
                                
                                // Get the updated handle
                                if let updatedHandle = self.handles[elementID]?[handleID] {
                                    // Tell element this handle changed
                                    elements[elementIndex].handleDidChange(updatedHandle)
                                }
                            }
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
                    (handle.id, handle)
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
        .init(id: .init(), value:.circle(Circle_(center: CGPoint(x: 150, y: 150), radius: 50))),
        .init(id: .init(), value:.circle(Circle_(center: CGPoint(x: 250, y: 150), radius: 50))),
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
            InteractiveHandle(id: "start", position: start),
            InteractiveHandle(id: "end", position: end),
        ]
    }
    mutating func handleDidChange(_ handle: InteractiveHandle) {
        switch handle.id {
        case "start":
            start = handle.position
        case "end":
            end = handle.position
        default:
            fatalError()
        }
    }
}

extension Circle_: InteractiveRepresentable {
    func makeHandles() -> [InteractiveHandle] {
        let edgePoint = CGPoint(x: center.x + radius, y: center.y)
        return [
            InteractiveHandle(id: "start", position: center),
            InteractiveHandle(id: "edge", position: edgePoint)
        ]
    }
    mutating func handleDidChange(_ handle: InteractiveHandle) {
        switch handle.id {
        case "start":
            center = handle.position
        case "edge":
            // Calculate radius from center to edge handle position
            radius = hypot(handle.position.x - center.x, handle.position.y - center.y)
        default:
            fatalError()
        }
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
    mutating func handleDidChange(_ handle: InteractiveHandle) {
        switch self {
        case .lineSegment(var segment):
            segment.handleDidChange(handle)
            self = .lineSegment(segment)
        case .circle(var circle):
            circle.handleDidChange(handle)
            self = .circle(circle)
        }
    }
}

extension Identified: InteractiveRepresentable where Value: InteractiveRepresentable {
    func makeHandles() -> [InteractiveHandle] {
        value.makeHandles()
    }
    mutating func handleDidChange(_ handle: InteractiveHandle) {
        value.handleDidChange(handle)
    }
}

extension Identified where ID == UUID {
    init(value: Value) {
        self.init(id: UUID(), value: value)
    }
}

