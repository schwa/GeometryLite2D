import CoreGraphics
import SwiftUI
public struct InteractiveHandle<ID: Hashable>: Identifiable {
    public var id: ID
    public var position: CGPoint

    public init(id: ID, position: CGPoint) {
        self.id = id
        self.position = position
    }
}

public protocol InteractiveRepresentable {
    associatedtype HandleID: Hashable
    func makeHandles() -> [InteractiveHandle<HandleID>]
    mutating func handleDidChange(id: HandleID, handles: inout [HandleID: InteractiveHandle<HandleID>])
}

public struct InteractiveCanvas <Element, ElementID>: View where Element: InteractiveRepresentable, ElementID: Hashable {
    @Binding
    var elements: [Element]

    var id: KeyPath<Element, ElementID>
    var snap: ((CGPoint, [CGPoint]) -> CGPoint)?
    var transform: CGAffineTransform

    @State
    private var handles: [ElementID: [Element.HandleID: InteractiveHandle<Element.HandleID>]] = [:]

    public init(elements: Binding<[Element]>, id: KeyPath<Element, ElementID>, snap: ((CGPoint, [CGPoint]) -> CGPoint)? = nil, transform: CGAffineTransform = .identity) {
        self._elements = elements
        self.id = id
        self.snap = snap
        self.transform = transform
    }

    public var body: some View {
        let inverseTransform = transform.inverted()
        ZStack {
            ForEach(Array(handles), id: \.key) { elementID, elementHandles in
                ForEach(Array(elementHandles), id: \.key) { handleID, _ in
                    let binding = Binding<CGPoint>(
                        get: {
                            let modelPosition = self.handles[elementID]?[handleID]?.position ?? .zero
                            return modelPosition.applying(transform)
                        },
                        set: { screenPosition in
                            let modelPosition = screenPosition.applying(inverseTransform)
                            if let elementIndex = elements.firstIndex(where: { $0[keyPath: id] == elementID }) {
                                // Update handle position in state
                                self.handles[elementID]?[handleID]?.position = modelPosition

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
                    let snapTargets = allHandlePositions(excluding: elementID, handleID: handleID)
                    let snapClosure: ((CGPoint) -> CGPoint)? = snap.map { snap in
                        { point in snap(point, snapTargets) }
                    }
                    DragHandle(position: binding, snap: snapClosure)
                }
            }
        }
        .onChange(of: elementIDs, initial: true) {
            rebuildHandles()
        }
    }

    private func rebuildHandles() {
        let currentIDs = Set(elementIDs)
        // Clear all and rebuild - simplest way to ensure consistency
        var newHandles: [ElementID: [Element.HandleID: InteractiveHandle<Element.HandleID>]] = [:]
        for (elementID, element) in zip(elementIDs, elements) {
            let elementHandles = element.makeHandles()
            newHandles[elementID] = Dictionary(uniqueKeysWithValues: elementHandles.map { handle in
                (handle.id, handle)
            })
        }
        handles = newHandles
    }

    private func allHandlePositions(excluding elementID: ElementID, handleID: Element.HandleID) -> [CGPoint] {
        var positions: [CGPoint] = []
        for (elID, elementHandles) in handles {
            for (hID, handle) in elementHandles {
                // Exclude the current handle being dragged
                if elID == elementID && hID == handleID {
                    continue
                }
                // Also exclude the partner handle on the same element (e.g., other end of same line segment)
                if elID == elementID {
                    continue
                }
                positions.append(handle.position)
            }
        }
        return positions
    }

    var elementIDs: [ElementID] {
        elements.map { $0[keyPath: id] }
    }

}
