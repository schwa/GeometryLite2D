import SwiftUI
import Geometry
import Visualization

struct InteractiveHandle<ID: Hashable>: Identifiable {
    var id: ID
    var position: CGPoint
}

protocol InteractiveRepresentable {
    associatedtype HandleID: Hashable
    func makeHandles() -> [InteractiveHandle<HandleID>]
    mutating func handleDidChange(id: HandleID, handles: inout [HandleID: InteractiveHandle<HandleID>])
}


struct InteractiveCanvas <Element, ElementID>: View where Element: InteractiveRepresentable, ElementID: Hashable {
    @Binding
    var elements: [Element]

    var id: KeyPath<Element, ElementID>

    @State
    var handles: [ElementID: [Element.HandleID: InteractiveHandle<Element.HandleID>]] = [:]

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
                                
                                // Get all handles for this element
                                if var elementHandles = self.handles[elementID] {
                                    // Tell element which handle changed, allowing it to update other handles
                                    elements[elementIndex].handleDidChange(id: handleID, handles: &elementHandles)
                                    // Save the potentially modified handles back
                                    self.handles[elementID] = elementHandles
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
    enum HandleID: String, Hashable {
        case start, end
    }
    
    func makeHandles() -> [InteractiveHandle<HandleID>] {
        return [
            InteractiveHandle(id: .start, position: start),
            InteractiveHandle(id: .end, position: end),
        ]
    }
    
    mutating func handleDidChange(id: HandleID, handles: inout [HandleID: InteractiveHandle<HandleID>]) {
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
    enum HandleID: String, Hashable {
        case center, edge
    }
    
    func makeHandles() -> [InteractiveHandle<HandleID>] {
        let edgePoint = CGPoint(x: center.x + radius, y: center.y)
        return [
            InteractiveHandle(id: .center, position: center),
            InteractiveHandle(id: .edge, position: edgePoint)
        ]
    }
    
    mutating func handleDidChange(id: HandleID, handles: inout [HandleID: InteractiveHandle<HandleID>]) {
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
    
    mutating func handleDidChange(id: AnyHashable, handles: inout [AnyHashable: InteractiveHandle<AnyHashable>]) {
        switch self {
        case .lineSegment(var segment):
            // Convert back to LineSegment's handle type
            if let typedId = id.base as? LineSegment.HandleID {
                var typedHandles = [LineSegment.HandleID: InteractiveHandle<LineSegment.HandleID>]()
                for (key, value) in handles {
                    if let typedKey = key.base as? LineSegment.HandleID {
                        typedHandles[typedKey] = InteractiveHandle(id: typedKey, position: value.position)
                    }
                }
                segment.handleDidChange(id: typedId, handles: &typedHandles)
                // Update handles with any changes
                for (key, value) in typedHandles {
                    handles[AnyHashable(key)] = InteractiveHandle(id: AnyHashable(key), position: value.position)
                }
                self = .lineSegment(segment)
            }
            
        case .circle(var circle):
            // Convert back to Circle's handle type
            if let typedId = id.base as? Circle_.HandleID {
                var typedHandles = [Circle_.HandleID: InteractiveHandle<Circle_.HandleID>]()
                for (key, value) in handles {
                    if let typedKey = key.base as? Circle_.HandleID {
                        typedHandles[typedKey] = InteractiveHandle(id: typedKey, position: value.position)
                    }
                }
                circle.handleDidChange(id: typedId, handles: &typedHandles)
                // Update handles with any changes
                for (key, value) in typedHandles {
                    handles[AnyHashable(key)] = InteractiveHandle(id: AnyHashable(key), position: value.position)
                }
                self = .circle(circle)
            }
        }
    }
}

extension Identified: InteractiveRepresentable where Value: InteractiveRepresentable {
    typealias HandleID = Value.HandleID
    
    func makeHandles() -> [InteractiveHandle<Value.HandleID>] {
        value.makeHandles()
    }
    
    mutating func handleDidChange(id: Value.HandleID, handles: inout [Value.HandleID: InteractiveHandle<Value.HandleID>]) {
        value.handleDidChange(id: id, handles: &handles)
    }
}

extension Identified where ID == UUID {
    init(value: Value) {
        self.init(id: UUID(), value: value)
    }
}

