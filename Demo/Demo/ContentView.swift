import SwiftUI
import Geometry
import Visualization

struct InteractiveHandle {
    var position: CGPoint
}

protocol InteractiveRepresentable {
    func makeHandles() -> [InteractiveHandle]
    mutating func handlesDidChange(_ handles: [InteractiveHandle])
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
                            if let elementIndex = elements.firstIndex(where: { $0[keyPath: id] == elementID }) {
                                      // Update handle position
                                      self.handles[elementID]?[handleID]?.position = newPosition

                                      // Get all handles for this element in order
                                      if let elementHandles = self.handles[elementID] {
                                          // Sort by UUID to maintain consistent ordering
                                          let sortedHandles = elementHandles
                                              .sorted(by: { $0.key.uuidString < $1.key.uuidString })
                                              .map { $0.value }

                                          // Update element with new handle positions
                                          elements[elementIndex].handlesDidChange(sortedHandles)
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
    mutating func handlesDidChange(_ handles: [InteractiveHandle]) {
        guard handles.count == 2 else { return }
        start = handles[0].position
        end = handles[1].position

    }
}

extension Circle_: InteractiveRepresentable {
    func makeHandles() -> [InteractiveHandle] {
        return [
            InteractiveHandle(position: center),
//            InteractiveHandle()
        ]
    }
    mutating func handlesDidChange(_ handles: [InteractiveHandle]) {
        guard handles.count == 1 else { return }
        center = handles[0].position
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
    mutating func handlesDidChange(_ handles: [InteractiveHandle]) {
        switch self {
        case .lineSegment(var segment):
            segment.handlesDidChange(handles)
            self = .lineSegment(segment)
        case .circle(var circle):
            circle.handlesDidChange(handles)
            self = .circle(circle)
        }
    }

}

extension Identified: InteractiveRepresentable where Value: InteractiveRepresentable {
    func makeHandles() -> [InteractiveHandle] {
        value.makeHandles()
    }
    mutating func handlesDidChange(_ handles: [InteractiveHandle]) {
        value.handlesDidChange(handles)
    }
}

extension Identified where ID == UUID {
    init(value: Value) {
        self.init(id: UUID(), value: value)
    }
}

