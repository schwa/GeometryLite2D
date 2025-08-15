import Geometry
import SwiftUI

struct LineSegmentProxy: InteractiveProxy {
    func makeDragHandles(shape: Binding<LineSegment>, proxy: Binding<Self>) -> some View {
        DragHandle(position: Binding(
            get: { shape.wrappedValue.start },
            set: { shape.wrappedValue.start = $0 }
        ))
        DragHandle(position: Binding(
            get: { shape.wrappedValue.end },
            set: { shape.wrappedValue.end = $0 }
        ))
    }
}

struct CircleProxy: InteractiveProxy {
    var edgePoint: CGPoint

    func makeDragHandles(shape: Binding<Circle_>, proxy: Binding<Self>) -> some View {
        DragHandle(position: Binding(
            get: { shape.wrappedValue.center },
            set: { newCenter in
                let oldCenter = shape.wrappedValue.center
                let delta = CGVector(dx: newCenter.x - oldCenter.x, dy: newCenter.y - oldCenter.y)
                shape.wrappedValue.center = newCenter
                proxy.wrappedValue.edgePoint.x += delta.dx
                proxy.wrappedValue.edgePoint.y += delta.dy
            }
        ))
        DragHandle(position: Binding(
            get: { proxy.wrappedValue.edgePoint },
            set: { newEdgePoint in
                proxy.wrappedValue.edgePoint = newEdgePoint
                let dx = newEdgePoint.x - shape.wrappedValue.center.x
                let dy = newEdgePoint.y - shape.wrappedValue.center.y
                shape.wrappedValue.radius = sqrt(dx * dx + dy * dy)
            }
        ))
    }
}
