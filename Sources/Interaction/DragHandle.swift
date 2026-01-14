import SwiftUI

public struct DragHandle: View {
    @Binding
    var position: CGPoint

    var snap: ((CGPoint) -> CGPoint)?

    public init(position: Binding<CGPoint>, snap: ((CGPoint) -> CGPoint)? = nil) {
        self._position = position
        self.snap = snap
    }

    public var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 6, height: 6)
            .padding(2)
            .background {
                Circle()
                    .fill(Color.blue)
            }
            .position(position)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newPosition = snap?(value.location) ?? value.location
                        position = newPosition
                    }
            )
    }
}
