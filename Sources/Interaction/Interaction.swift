import SwiftUI
import Visualization

public protocol Interactable {
    var dragHandles: [Binding<CGPoint>] { get }
}

struct DragHandle {
    // TODO : This is a binding
    var getter: () -> CGPoint
    var setter: (CGPoint) -> Void
}

public struct InteractiveCanvas: View {
    @Binding
    var elements: [any Interactable & VisualizationRepresentable]

    var renderer: ((inout GraphicsContext, CGSize) -> Void)?

    public init(elements: Binding<[any Interactable & VisualizationRepresentable]>, renderer: ((inout GraphicsContext, CGSize) -> Void)? = nil) {
        self._elements = elements
        self.renderer = renderer
    }

    public var body: some View {
        ZStack {
            Canvas { context, size in
                for element in elements {
                    element.visualize(in: context, style: .init(), transform: .identity)
                }
                renderer?(&context, size)
            }
            ForEach(Array(elements.enumerated()), id: \.offset) { offset, element in
                ForEach(Array(element.dragHandles.enumerated()), id: \.offset) { offset, handle in
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 10, height: 10)
                        .position(handle.wrappedValue)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    handle.wrappedValue = value.location

                                }
                        )
                }
            }
        }
    }
}


// OLD

