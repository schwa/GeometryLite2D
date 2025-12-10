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

    @State
    private var handles: [ElementID: [Element.HandleID: InteractiveHandle<Element.HandleID>]] = [:]

    public init(elements: Binding<[Element]>, id: KeyPath<Element, ElementID>, handles: [ElementID : [Element.HandleID : InteractiveHandle<Element.HandleID>]] = [:]) {
        self._elements = elements
        self.id = id
        self.handles = handles
    }


    public var body: some View {
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

    var elementIDs: [ElementID] {
        elements.map { $0[keyPath: id] }
    }

}
