import SwiftUI
import Visualization

public protocol InteractiveProxyRepresentable {
    associatedtype Proxy: InteractiveProxy

    func makeInteractiveProxy() -> Proxy
}

public struct Handle {
    let getter: (any InteractiveProxy) -> CGPoint
    let setter: (inout any InteractiveProxy, CGPoint) -> Void

    public init<T>(getter: @escaping (T) -> CGPoint, setter: @escaping (inout T, CGPoint) -> Void) where T: InteractiveProxy {
        self.getter = { proxy in
            guard let proxy = proxy as? T else {
                fatalError("Proxy type mismatch")
            }
            return getter(proxy)
        }
        self.setter = { proxy, point in
            guard var typedProxy = proxy as? T else {
                fatalError("Proxy type mismatch")
            }
            setter(&typedProxy, point)
            proxy = typedProxy
        }
    }

}

public protocol InteractiveProxy {
    var handles: [Handle] { get }
    func draw(in context: GraphicsContext)
}


public struct InteractiveCanvas <Element, ElementID>: View where ElementID: Hashable {

    var elements: [Element]

    @State
    var proxies: [any InteractiveProxy] = []

    let id: (Element) -> ElementID

    let proxy: (Element) -> (any InteractiveProxy)

    public init(elements: [Element], id: @escaping (Element) -> (ElementID), proxy: @escaping (Element) -> (any InteractiveProxy)) {
        self.elements = elements
        self.id = id
        self.proxy = proxy
    }

    public var body: some View {
        let ids = elements.map(id)
        ZStack {
            Canvas { context, size in
                for proxy in proxies {
                    proxy.draw(in: context)
                }
            }
            ForEach(Array(proxies.enumerated()), id: \.0) { offset, proxy in
                let handles = proxy.handles
                ForEach(Array(handles.enumerated()), id: \.offset) { _, handle in
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 10, height: 10)
                        .position(handle.getter(proxy))
                        .gesture(DragGesture().onChanged({ value in
                            let location = value.location
                            var tmp = proxy
                            handle.setter(&tmp, location)
                            self.proxies[offset] = tmp
                        }))

                }
            }
        }
        .onChange(of: ids, initial: true) { oldValue, newValue in
            // TODO: DO DIFF
            print("CHANGED")
            proxies = elements.map(proxy)
        }
    }
}
