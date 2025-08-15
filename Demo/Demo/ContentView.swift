import SwiftUI
import Visualization
import Interaction
import Geometry

extension Circle_: @retroactive InteractiveProxyRepresentable {
    public struct Proxy: InteractiveProxy {
        var center: CGPoint
        var edgePoint: CGPoint

        init(center: CGPoint, edgePoint: CGPoint) {
            self.center = center
            self.edgePoint = edgePoint
        }

        public var handles: [Handle] {
            return [
                Handle(getter: { (proxy: Proxy) -> CGPoint in
                    proxy.center
                }, setter: { (proxy: inout Proxy, value: CGPoint) in
                    let delta = value - proxy.center
                    proxy.center = value
                    proxy.edgePoint += delta
                }),
                Handle(getter: { (proxy: Proxy) -> CGPoint in
                    proxy.edgePoint
                }, setter: { (proxy: inout Proxy, value: CGPoint) in
                    proxy.edgePoint = value
                })
            ]
        }

        public func draw(in context: GraphicsContext) {
            let circle = Circle(center: center, radius: edgePoint.distance(to: center))
            context.stroke(Path(representable: circle), with: .color(.black))
        }
    }

    public func makeInteractiveProxy() -> Proxy {
        return Proxy(center: center, edgePoint: center + [0, radius])
    }
    
    public func updateFromProxy(_ proxy: Proxy) -> Circle_ {
        let newRadius = proxy.edgePoint.distance(to: proxy.center)
        return Circle_(center: proxy.center, radius: newRadius)
    }
}

extension LineSegment: @retroactive InteractiveProxyRepresentable {
    public struct Proxy: InteractiveProxy {
        var start: CGPoint
        var end: CGPoint
        
        init(start: CGPoint, end: CGPoint) {
            self.start = start
            self.end = end
        }
        
        public var handles: [Handle] {
            return [
                Handle(getter: { (proxy: Proxy) -> CGPoint in
                    proxy.start
                }, setter: { (proxy: inout Proxy, value: CGPoint) in
                    proxy.start = value
                }),
                Handle(getter: { (proxy: Proxy) -> CGPoint in
                    proxy.end
                }, setter: { (proxy: inout Proxy, value: CGPoint) in
                    proxy.end = value
                })
            ]
        }
        
        public func draw(in context: GraphicsContext) {
            let segment = LineSegment(start: start, end: end)
            context.stroke(Path(representable: segment), with: .color(.black))
        }
    }
    
    public func makeInteractiveProxy() -> Proxy {
        return Proxy(start: start, end: end)
    }
    
    public func updateFromProxy(_ proxy: Proxy) -> LineSegment {
        return LineSegment(start: proxy.start, end: proxy.end)
    }
}

struct ContentView: View {
    @State
    var shapes: [any InteractiveProxyRepresentable] = [
        LineSegment(start: CGPoint(x: 100, y: 100), end: CGPoint(x: 250, y: 100)),
        Circle_(center: CGPoint(x: 150, y: 150), radius: 50),
        Circle_(center: CGPoint(x: 250, y: 150), radius: 50),
    ]

    @State
    var intersection: Intersection<CGFloat, CGFloat>?

    var body: some View {
        VStack {
            InteractiveCanvas(
                elements: Binding(
                    get: { Array(shapes.enumerated()) },
                    set: { newValue in 
                        shapes = newValue.map { $0.1 }
                    }
                ),
                id: \.0,  // Use the index as ID
                makeProxy: { (_, element) in
                    element.makeInteractiveProxy()
                },
                updateElement: { element, proxy in
                    let (index, element) = element
                    if let circle = element as? Circle_, let circleProxy = proxy as? Circle_.Proxy {
                        return (index, circle.updateFromProxy(circleProxy) as any InteractiveProxyRepresentable)
                    } else if let segment = element as? LineSegment, let segmentProxy = proxy as? LineSegment.Proxy {
                        return (index, segment.updateFromProxy(segmentProxy) as any InteractiveProxyRepresentable)
                    }
                    return (index, element)
                }
            )
        }
    }
}

#Preview {
    ContentView()
}

