import SwiftUI

public struct VisualizationCanvas <Element>: View where Element: VisualizationRepresentable {
    let elements: [Element]

    public init(elements: [Element]) {
        self.elements = elements
    }

    public var body: some View {
        Canvas { context, _ in
            for element in elements {
                element.visualize(in: context, style: .init(), transform: .identity)
            }
        }
    }
}
