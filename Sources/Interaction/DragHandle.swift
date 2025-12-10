import SwiftUI

public struct DragHandle: View {
    @Binding
    var position: CGPoint

    public init(position: Binding<CGPoint>) {
        self._position = position
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
                        position = value.location
                    }
            )
    }
}
