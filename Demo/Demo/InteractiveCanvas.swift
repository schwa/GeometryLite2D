import SwiftUI
import Visualization

protocol InteractiveProxy {
    associatedtype Element
    associatedtype Content: View

    @ViewBuilder
    func makeDragHandles(shape: Binding<Element>, proxy: Binding<Self>) -> Content
}

class AnyInteractiveProxy<Element> {
    private var _makeDragHandles: (Binding<Element>, AnyInteractiveProxy<Element>) -> AnyView
    
    init<P: InteractiveProxy>(_ proxy: P) where P.Element == Element {
        var storedProxy = proxy
        self._makeDragHandles = { binding, anyProxy in
            let proxyBinding = Binding<P>(
                get: { storedProxy },
                set: { storedProxy = $0 }
            )
            return AnyView(storedProxy.makeDragHandles(shape: binding, proxy: proxyBinding))
        }
    }
    
    func makeDragHandles(shape: Binding<Element>) -> AnyView {
        _makeDragHandles(shape, self)
    }
}

struct InteractiveCanvas <Element, ElementID>: View where Element: VisualizationRepresentable, ElementID: Hashable {
    @Binding
    var elements: [Element]

    var id: KeyPath<Element, ElementID>

    var makeProxy: (Element) -> AnyInteractiveProxy<Element>

    @State
    var proxies: [ElementID: AnyInteractiveProxy<Element>] = [:]

    var ids : [ElementID] {
        elements.map { $0[keyPath: id] }
    }

    var body: some View {
        ZStack {
            Canvas { context, size in
                for element in elements {
                    element.visualize(in: context, style: .init(), transform: .identity)
                }
            }
            ForEach(elements, id: id) { element in
                dragHandles(for: element)
            }
        }
        .onChange(of: ids, initial: true) {
            for element in elements {
                let id = element[keyPath: id]
                proxies[id] = makeProxy(element)
            }
        }
    }

    @ViewBuilder
    func dragHandles(for element: Element) -> some View {
        let id = element[keyPath: id]
        if let proxy = proxies[id] {
            if let index = elements.firstIndex(where: { $0[keyPath: self.id] == id }) {
                let binding = Binding<Element>(
                    get: { elements[index] },
                    set: { elements[index] = $0 }
                )
                proxy.makeDragHandles(shape: binding)
            }
        }
    }
}
