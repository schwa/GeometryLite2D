import Geometry
import SwiftUI

struct LineSegmentProxy: InteractiveProxy {
    func makeDragHandles(shape: Binding<LineSegment>) -> some View {
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

    func makeDragHandles(shape: Binding<Circle_>) -> some View {
        DragHandle(position: Binding(
            get: { shape.wrappedValue.center },
            set: { shape.wrappedValue.center = $0 }
        ))
        DragHandle(position: Binding(
            get: { edgePoint },
            set: { _ in }
        ))
    }
}
